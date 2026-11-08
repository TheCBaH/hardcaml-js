(* Pure OCaml, on 16-bit limbs read and written through 16-bit [Bytes] accessors. A limb
   product plus two limbs and a carry is below 2^32, so every intermediate is exact in
   32-bit [int] arithmetic; the code only uses [+], [-], [*], [land], [lor], [lsl] and
   [lsr] on them, never comparisons. Neither [Int64] nor 63-bit values are needed. *)

let words_of_width width = (width + 63) lsr 6
let get b byte = Bytes.get_uint16_le b byte
let set b byte v = Bytes.set_uint16_le b byte (v land 0xffff)
let header_width b = get b 0 lor (get b 2 lsl 16)

(* Clear the bits at and above [width] in the last word. *)
let mask b ~address ~width =
  let bits = width land 63 in
  if bits <> 0
  then (
    let base = (address + words_of_width width - 1) lsl 3 in
    for k = 0 to 3 do
      let low = k lsl 4 in
      let byte = base + (k lsl 1) in
      if bits <= low
      then set b byte 0
      else if bits < low + 16
      then set b byte (get b byte land ((1 lsl (bits - low)) - 1))
    done)
;;

let add_at ~dst ~dst_address ~a ~a_address ~b ~b_address ~width =
  let dst_base = dst_address lsl 3
  and a_base = a_address lsl 3
  and b_base = b_address lsl 3 in
  let carry = ref 0 in
  for i = 0 to (words_of_width width lsl 2) - 1 do
    let o = i lsl 1 in
    let s = get a (a_base + o) + get b (b_base + o) + !carry in
    set dst (dst_base + o) s;
    carry := s lsr 16
  done;
  mask dst ~address:dst_address ~width
;;

let sub_at ~dst ~dst_address ~a ~a_address ~b ~b_address ~width =
  let dst_base = dst_address lsl 3
  and a_base = a_address lsl 3
  and b_base = b_address lsl 3 in
  let borrow = ref 0 in
  for i = 0 to (words_of_width width lsl 2) - 1 do
    let o = i lsl 1 in
    let d = get a (a_base + o) - get b (b_base + o) - !borrow in
    set dst (dst_base + o) d;
    borrow := (d lsr 16) land 1
  done;
  mask dst ~address:dst_address ~width
;;

(* [r] (zeroed, [m + n] limbs) := a * b for [m]- and [n]-limb unsigned operands. *)
let mulu_limbs r a ~a_base b ~b_base ~m ~n =
  for j = 0 to n - 1 do
    let vj = get b (b_base + (j lsl 1)) in
    let k = ref 0 in
    for i = 0 to m - 1 do
      let o = (i + j) lsl 1 in
      let t = (get a (a_base + (i lsl 1)) * vj) + get r o + !k in
      set r o t;
      k := t lsr 16
    done;
    set r ((j + m) lsl 1) !k
  done
;;

(* [r] -= [src] at limb [offset], over [count] limbs; the final borrow is dropped. *)
let sub_limbs r ~offset src ~count =
  let borrow = ref 0 in
  for j = 0 to count - 1 do
    let o = (offset + j) lsl 1 in
    let d = get r o - get src (j lsl 1) - !borrow in
    set r o d;
    borrow := (d lsr 16) land 1
  done
;;

let finish_mul r ~dst ~dst_address ~width =
  Bytes.blit r 0 dst (dst_address lsl 3) (words_of_width width lsl 3);
  mask dst ~address:dst_address ~width
;;

let umul_at ~dst ~dst_address ~a ~a_address ~b ~b_address ~width_a ~width_b =
  let m = words_of_width width_a lsl 2
  and n = words_of_width width_b lsl 2 in
  let r = Bytes.make ((m + n) lsl 1) '\000' in
  mulu_limbs r a ~a_base:(a_address lsl 3) b ~b_base:(b_address lsl 3) ~m ~n;
  finish_mul r ~dst ~dst_address ~width:(width_a + width_b)
;;

(* A copy of the operand with the last word sign extended from bit [width - 1]. *)
let sign_extended src ~address ~width =
  let words = words_of_width width in
  let c = Bytes.sub src (address lsl 3) (words lsl 3) in
  let bit = (width - 1) land 63 in
  let k = bit lsr 4
  and s = bit land 15 in
  let o = ((words - 1) lsl 3) + (k lsl 1) in
  if (get c o lsr s) land 1 = 1
  then (
    set c o (get c o lor (0xffff lsl s));
    for k = k + 1 to 3 do
      set c (((words - 1) lsl 3) + (k lsl 1)) 0xffff
    done);
  c
;;

let smul_at ~dst ~dst_address ~a ~a_address ~b ~b_address ~width_a ~width_b =
  let ea = sign_extended a ~address:a_address ~width:width_a
  and eb = sign_extended b ~address:b_address ~width:width_b in
  let m = words_of_width width_a lsl 2
  and n = words_of_width width_b lsl 2 in
  let r = Bytes.make ((m + n) lsl 1) '\000' in
  mulu_limbs r ea ~a_base:0 eb ~b_base:0 ~m ~n;
  if get ea ((m - 1) lsl 1) land 0x8000 <> 0 then sub_limbs r ~offset:m eb ~count:n;
  if get eb ((n - 1) lsl 1) land 0x8000 <> 0 then sub_limbs r ~offset:n ea ~count:m;
  finish_mul r ~dst ~dst_address ~width:(width_a + width_b)
;;

(* [Bits.t] layout: the data starts one word after the width header. *)
let add (dst : Bits0.t) (a : Bits0.t) (b : Bits0.t) =
  let dst = (dst :> Bytes.t) and a = (a :> Bytes.t) and b = (b :> Bytes.t) in
  add_at ~dst ~dst_address:1 ~a ~a_address:1 ~b ~b_address:1 ~width:(header_width dst)
;;

let sub (dst : Bits0.t) (a : Bits0.t) (b : Bits0.t) =
  let dst = (dst :> Bytes.t) and a = (a :> Bytes.t) and b = (b :> Bytes.t) in
  sub_at ~dst ~dst_address:1 ~a ~a_address:1 ~b ~b_address:1 ~width:(header_width dst)
;;

let umul (dst : Bits0.t) (a : Bits0.t) (b : Bits0.t) =
  let dst = (dst :> Bytes.t) and a = (a :> Bytes.t) and b = (b :> Bytes.t) in
  umul_at
    ~dst
    ~dst_address:1
    ~a
    ~a_address:1
    ~b
    ~b_address:1
    ~width_a:(header_width a)
    ~width_b:(header_width b)
;;

let smul (dst : Bits0.t) (a : Bits0.t) (b : Bits0.t) =
  let dst = (dst :> Bytes.t) and a = (a :> Bytes.t) and b = (b :> Bytes.t) in
  smul_at
    ~dst
    ~dst_address:1
    ~a
    ~a_address:1
    ~b
    ~b_address:1
    ~width_a:(header_width a)
    ~width_b:(header_width b)
;;

type t = Bits0.t

module Packed = struct
  let add t ~dst_address ~src_address_a ~src_address_b ~width_in_bits =
    add_at
      ~dst:t
      ~dst_address
      ~a:t
      ~a_address:src_address_a
      ~b:t
      ~b_address:src_address_b
      ~width:width_in_bits
  ;;

  let sub t ~dst_address ~src_address_a ~src_address_b ~width_in_bits =
    sub_at
      ~dst:t
      ~dst_address
      ~a:t
      ~a_address:src_address_a
      ~b:t
      ~b_address:src_address_b
      ~width:width_in_bits
  ;;

  let umul t ~dst_address ~src_address_a ~src_address_b ~width_in_bits_a ~width_in_bits_b =
    umul_at
      ~dst:t
      ~dst_address
      ~a:t
      ~a_address:src_address_a
      ~b:t
      ~b_address:src_address_b
      ~width_a:width_in_bits_a
      ~width_b:width_in_bits_b
  ;;

  let smul t ~dst_address ~src_address_a ~src_address_b ~width_in_bits_a ~width_in_bits_b =
    smul_at
      ~dst:t
      ~dst_address
      ~a:t
      ~a_address:src_address_a
      ~b:t
      ~b_address:src_address_b
      ~width_a:width_in_bits_a
      ~width_b:width_in_bits_b
  ;;
end
