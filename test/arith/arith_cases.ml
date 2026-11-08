(* Deterministic cases for Bits_arith. The generator and the digest only use 16-bit safe
   arithmetic, so the same cases and digest come out on native and JavaScript. *)

module type S = Hardcaml.Bits_arith.S

type op =
  | Add
  | Sub
  | Umul
  | Smul

type case =
  { name : string
  ; op : op
  ; width_a : int
  ; width_b : int
  ; a : string (* operand words, little endian, as they were before the operation *)
  ; b : string
  ; oracle : bool (* the operands are masked and read before they are written *)
  ; run : (module S) -> Bytes.t array * string (* all buffers, and the result words *)
  }

let state = ref 0x1234

let rand16 () =
  state := ((!state * 25173) + 13849) land 0xffff;
  (!state lxor (!state lsr 7)) land 0xffff
;;

let rand n = rand16 () mod n

let limb () =
  match rand 8 with
  | 0 -> 0
  | 1 -> 0xffff
  | 2 -> 0x8000
  | 3 -> 0x7fff
  | _ -> rand16 ()
;;

let words_of_width w = (w + 63) / 64

let fill b ~off ~len =
  for i = 0 to (len / 2) - 1 do
    Bytes.set_uint16_le b (off + (2 * i)) (limb ())
  done
;;

(* Clear the bits at and above [width] of the operand words at byte [off]. *)
let clear_above b ~off ~width =
  for bit = width to (words_of_width width * 64) - 1 do
    let i = off + (bit / 8) in
    Bytes.set b i (Char.chr (Char.code (Bytes.get b i) land lnot (1 lsl (bit mod 8))))
  done
;;

let widths =
  [ 1; 2; 7; 8; 15; 16; 17; 30; 31; 32; 33; 34; 47; 48; 49; 62; 63; 64; 65; 66; 90; 127
  ; 128; 129; 191; 192; 193; 255; 256; 257; 321 ]
;;

let unpacked width ~masked =
  let b = Bytes.make (8 + (words_of_width width * 8)) '\000' in
  Bytes.set_uint16_le b 0 (width land 0xffff);
  Bytes.set_uint16_le b 2 (width lsr 16);
  fill b ~off:8 ~len:(Bytes.length b - 8);
  if masked then clear_above b ~off:8 ~width;
  b
;;

let operand b ~off ~width = Bytes.sub_string b off (words_of_width width * 8)

let clone = Array.map Bytes.copy


let run_unpacked op ~contents ~dst ~a ~b ~width_a ~width_b =
  fun (module M : S) ->
  let c = clone contents in
  let bits c i : M.t = Obj.magic c.(i) (* [Bits.t] is a private [Bytes.t] *) in
  (match op with
   | Add -> M.add (bits c dst) (bits c a) (bits c b)
   | Sub -> M.sub (bits c dst) (bits c a) (bits c b)
   | Umul -> M.umul (bits c dst) (bits c a) (bits c b)
   | Smul -> M.smul (bits c dst) (bits c a) (bits c b));
  let width = if op = Add || op = Sub then width_a else width_a + width_b in
  c, operand c.(dst) ~off:8 ~width
;;

let run_packed op ~contents ~dst ~a ~b ~width_a ~width_b =
  fun (module M : S) ->
  let c = clone contents in
  let t = c.(0) in
  (match op with
   | Add ->
     M.Packed.add t ~dst_address:dst ~src_address_a:a ~src_address_b:b ~width_in_bits:width_a
   | Sub ->
     M.Packed.sub t ~dst_address:dst ~src_address_a:a ~src_address_b:b ~width_in_bits:width_a
   | Umul ->
     M.Packed.umul
       t
       ~dst_address:dst
       ~src_address_a:a
       ~src_address_b:b
       ~width_in_bits_a:width_a
       ~width_in_bits_b:width_b
   | Smul ->
     M.Packed.smul
       t
       ~dst_address:dst
       ~src_address_a:a
       ~src_address_b:b
       ~width_in_bits_a:width_a
       ~width_in_bits_b:width_b);
  let width = if op = Add || op = Sub then width_a else width_a + width_b in
  c, Bytes.sub_string t (dst * 8) (words_of_width width * 8)
;;

let ops = [ Add; Sub; Umul; Smul ]

let op_name = function
  | Add -> "add"
  | Sub -> "sub"
  | Umul -> "umul"
  | Smul -> "smul"
;;

let pairs op =
  let diagonal = List.map (fun w -> w, w) widths in
  match op with
  | Add | Sub -> diagonal
  | Umul | Smul ->
    diagonal
    @ List.concat_map
        (fun wa ->
          List.filter_map (fun wb -> if rand 3 = 0 then Some (wa, wb) else None) widths)
        widths
;;

let iter f =
  state := 0x1234;
  List.iter
    (fun op ->
      let arith = op = Add || op = Sub in
      List.iter
        (fun (width_a, width_b) ->
          let words_a = words_of_width width_a
          and words_b = words_of_width width_b in
          let width_dst = if arith then width_a else width_a + width_b in
          let words_dst = words_of_width width_dst in
          for _ = 0 to 1 do
            List.iter
              (fun masked ->
                let case layout ~a ~b ~oracle run =
                  f
                    { name =
                        Printf.sprintf
                          "%s %d %d %s %s"
                          (op_name op)
                          width_a
                          width_b
                          (if masked then "masked" else "garbage")
                          layout
                    ; op
                    ; width_a
                    ; width_b
                    ; a
                    ; b
                    ; oracle = oracle && masked
                    ; run
                    }
                in
                (* [Bits.t] layout: distinct operands, and the aliases Hardcaml allows. *)
                let ba = unpacked width_a ~masked
                and bb = unpacked width_b ~masked
                and bd = unpacked width_dst ~masked:false in
                let a = operand ba ~off:8 ~width:width_a
                and b = operand bb ~off:8 ~width:width_b in
                let bits layout contents ~dst ~a:ia ~b:ib =
                  case
                    layout
                    ~a
                    ~b
                    ~oracle:true
                    (run_unpacked op ~contents ~dst ~a:ia ~b:ib ~width_a ~width_b)
                in
                bits "bits" [| bd; ba; bb |] ~dst:0 ~a:1 ~b:2;
                if arith
                then (
                  bits "bits dst=a" [| ba; bb |] ~dst:0 ~a:0 ~b:1;
                  bits "bits dst=b" [| ba; bb |] ~dst:1 ~a:0 ~b:1);
                if width_a = width_b
                then
                  case
                    "bits a=b"
                    ~a
                    ~b:a
                    ~oracle:true
                    (run_unpacked
                       op
                       ~contents:[| bd; ba |]
                       ~dst:0
                       ~a:1
                       ~b:1
                       ~width_a
                       ~width_b);
                (* Packed layout: one buffer, with fresh and overlapping destinations. *)
                let a_address = 1 + rand 2 in
                let b_address = a_address + words_a + rand 2 in
                let fresh = b_address + words_b + rand 2 in
                let total = fresh + words_dst + 2 in
                let buf = Bytes.make (total * 8) '\000' in
                fill buf ~off:0 ~len:(total * 8);
                if masked
                then (
                  clear_above buf ~off:(a_address * 8) ~width:width_a;
                  clear_above buf ~off:(b_address * 8) ~width:width_b);
                let a = operand buf ~off:(a_address * 8) ~width:width_a
                and b = operand buf ~off:(b_address * 8) ~width:width_b in
                List.iter
                  (fun (layout, dst, oracle) ->
                    case
                      ("packed " ^ layout)
                      ~a
                      ~b
                      ~oracle
                      (run_packed
                         op
                         ~contents:[| buf |]
                         ~dst
                         ~a:a_address
                         ~b:b_address
                         ~width_a
                         ~width_b))
                  [ "fresh", fresh, true
                  ; "dst=a", a_address, true
                  ; "dst=b", b_address, true
                  ; "dst=a-1", a_address - 1, false
                  ; "dst=a+1", a_address + 1, false
                  ; "dst=b+1", b_address + 1, false
                  ; "dst=b-1", b_address - 1, false
                  ])
              [ true; false ]
          done)
        (pairs op))
    ops
;;

(* A hash of every byte of the final buffers and the result words, and a case count, per
   operation. *)
let op_index = function
  | Add -> 0
  | Sub -> 1
  | Umul -> 2
  | Smul -> 3
;;

let digests = Array.make 4 0
let counts = Array.make 4 0

let reset () =
  Array.fill digests 0 4 0;
  Array.fill counts 0 4 0
;;

let add_digest op (buffers, result) =
  let i = op_index op in
  counts.(i) <- counts.(i) + 1;
  let mix v = digests.(i) <- ((digests.(i) * 33) + v) land 0xffffff in
  Array.iter
    (fun b ->
      for i = 0 to (Bytes.length b / 2) - 1 do
        mix (Bytes.get_uint16_le b (2 * i))
      done)
    buffers;
  String.iter (fun c -> mix (Char.code c)) result
;;

let print_digests () =
  List.iter
    (fun op ->
      Printf.printf
        "%-4s cases=%d digest=%d\n"
        (op_name op)
        counts.(op_index op)
        digests.(op_index op))
    ops
;;
