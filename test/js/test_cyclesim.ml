(* Cyclesim of a counter, an enabled register, a synchronous RAM and wide arithmetic.
   Runs natively and under js_of_ocaml (Node) against the same expected output. *)

open Hardcaml

(* A 16-bit generator whose products stay below 2^32, so it behaves the same on 32-bit
   JavaScript integers. *)
let state = ref 0x2468

let rand16 () =
  state := ((!state * 25173) + 13849) land 0xffff;
  (!state lxor (!state lsr 7)) land 0xffff
;;

let random_bits width =
  let chunks = List.init ((width + 15) / 16) (fun _ -> Bits.of_int ~width:16 (rand16 ())) in
  Bits.select (Bits.concat_msb chunks) (width - 1) 0
;;

let design =
  let open Signal in
  let clock = input "clock" 1 in
  let clear = input "clear" 1 in
  let spec = Reg_spec.create ~clock ~clear () in
  let enable = input "enable" 1 in
  let data = input "data" 16 in
  let counter = reg_fb spec ~enable ~width:8 ~f:(fun d -> d +:. 1) in
  let held = reg spec ~enable data in
  (* The read data appears one cycle after the address. *)
  let ram =
    Ram.create
      ~collision_mode:Read_before_write
      ~size:16
      ~write_ports:
        [| { Write_port.write_clock = clock
           ; write_address = input "write_address" 4
           ; write_enable = input "write_enable" 1
           ; write_data = data
           }
        |]
      ~read_ports:
        [| { Read_port.read_clock = clock
           ; read_address = input "read_address" 4
           ; read_enable = vdd
           }
        |]
      ()
  in
  (* Registered, so that the arithmetic goes through the simulator's packed operations. *)
  let r s = reg (Reg_spec.create ~clock ()) ~enable:vdd s in
  let a = input "a" 33
  and b = input "b" 33
  and c = input "c" 65
  and d = input "d" 65 in
  Circuit.create_exn
    ~name:"trace"
    [ output "counter" counter
    ; output "held" held
    ; output "ram" ram.(0)
    ; output "add33" (r (a +: b))
    ; output "sub33" (r (a -: b))
    ; output "umul33" (r (a *: b))
    ; output "smul33" (r (a *+ b))
    ; output "add65" (r (c +: d))
    ; output "sub65" (r (c -: d))
    ; output "umul65" (r (c *: d))
    ; output "smul65" (r (c *+ d))
    ]
;;

let inputs =
  [ "clear", 1
  ; "enable", 1
  ; "data", 16
  ; "write_address", 4
  ; "write_enable", 1
  ; "read_address", 4
  ; "a", 33
  ; "b", 33
  ; "c", 65
  ; "d", 65
  ]
;;

(* Each row is the inputs applied and the outputs after the clock edge, by name. *)
let rows =
  lazy
    (state := 0x2468;
     let sim = Cyclesim.create design in
     List.init 200 (fun cycle ->
       let applied =
         List.map
           (fun (name, width) ->
             let value =
               if name = "clear"
               then Bits.of_int ~width (if cycle = 0 || cycle = 120 then 1 else 0)
               else random_bits width
             in
             Cyclesim.in_port sim name := value;
             name, Bits.to_string value)
           inputs
       in
       Cyclesim.cycle sim;
       applied
       @ List.map
           (fun (name, value) -> name, Bits.to_string !value)
           (Cyclesim.outputs sim)))
;;

let show ~cycles columns =
  List.iteri
    (fun cycle row ->
      if cycle < cycles
      then
        print_endline
          (String.concat
             " "
             (Printf.sprintf "%3d" cycle
              :: List.map (fun name -> name ^ "=" ^ List.assoc name row) columns)))
    (Lazy.force rows)
;;

let%expect_test "counter and enabled register" =
  show ~cycles:10 [ "clear"; "enable"; "data"; "counter"; "held" ];
  [%expect {|
    0 clear=1 enable=0 data=0101100100111101 counter=00000000 held=0000000000000000
    1 clear=0 enable=1 data=0111100000101010 counter=00000001 held=0111100000101010
    2 clear=0 enable=0 data=0111111100100011 counter=00000001 held=0111100000101010
    3 clear=0 enable=0 data=1111011010001111 counter=00000001 held=0111100000101010
    4 clear=0 enable=0 data=0011001100011100 counter=00000001 held=0111100000101010
    5 clear=0 enable=1 data=0010000000110111 counter=00000010 held=0010000000110111
    6 clear=0 enable=0 data=1100001001101111 counter=00000010 held=0010000000110111
    7 clear=0 enable=0 data=0100000100011110 counter=00000010 held=0010000000110111
    8 clear=0 enable=1 data=0111010001001111 counter=00000011 held=0111010001001111
    9 clear=0 enable=0 data=0110110010001011 counter=00000011 held=0111010001001111
    |}]
;;

let%expect_test "synchronous RAM" =
  show ~cycles:10 [ "write_enable"; "write_address"; "data"; "read_address"; "ram" ];
  [%expect {|
    0 write_enable=0 write_address=0011 data=0101100100111101 read_address=1001 ram=0000000000000000
    1 write_enable=1 write_address=1001 data=0111100000101010 read_address=0111 ram=0000000000000000
    2 write_enable=0 write_address=0001 data=0111111100100011 read_address=0010 ram=0000000000000000
    3 write_enable=0 write_address=1000 data=1111011010001111 read_address=0001 ram=0000000000000000
    4 write_enable=1 write_address=1000 data=0011001100011100 read_address=1010 ram=0000000000000000
    5 write_enable=0 write_address=1011 data=0010000000110111 read_address=1010 ram=0000000000000000
    6 write_enable=0 write_address=0101 data=1100001001101111 read_address=0000 ram=0000000000000000
    7 write_enable=1 write_address=1000 data=0100000100011110 read_address=1000 ram=0011001100011100
    8 write_enable=0 write_address=1101 data=0111010001001111 read_address=1010 ram=0000000000000000
    9 write_enable=0 write_address=1111 data=0110110010001011 read_address=0011 ram=0000000000000000
    |}]
;;

let%expect_test "33-bit arithmetic" =
  show ~cycles:3 [ "a"; "b"; "add33"; "sub33"; "umul33"; "smul33" ];
  [%expect {|
    0 a=011110001010010101001010111001001 b=111100101100011101100110011001101 add33=011010110110110010110001010010110 sub33=100001011101110111100100011111100 umul33=011100100110101000111001100010110110001010100101000001110111110101 smul33=111110011100010011101110101001101110001010100101000001110111110101
    1 a=011111111000100010011001000010001 b=111101011101001110001010001100000 add33=011101010101110000100011001110001 sub33=100010011011010100001110110110001 umul33=011110100111011100011100111000101101000010011100110001101001100000 smul33=111110101110111010000011110110100101000010011100110001101001100000
    2 a=000111010110001000111010000110111 b=001100011000100111000001001111011 add33=010011101110101111111011010110010 sub33=111010111101100001111000110111100 umul33=000001011010111110011100110111100111100100011111001100010001101101 smul33=000001011010111110011100110111100111100100011111001100010001101101
    |}]
;;

let%expect_test "65-bit arithmetic" =
  show ~cycles:3 [ "c"; "d"; "add65"; "sub65"; "umul65"; "smul65" ];
  [%expect {|
    0 c=11100011101001000100111101011110111110001101000111010001100011100 d=10110001100111001101001000010010110100000101101110110010011010101 add65=10010101010000010010000101110001110010010010110110000011111110001 sub65=00110010000001110111110101001100001010000111011000011111001000111 umul65=1001110111110000000011011100111010001011110110010011100100010100110100010010011100110010110110010100010001111000011010011001001100 smul65=0000100010101110111011000101110011000010101010111011010100011100010100010010011100110010110110010100010001111000011010011001001100
    1 c=11100001111101010111000010101111010101001101101011001000011101110 d=01010010001000001001110001011000110001100110000100110000111100100 add65=00110100000101100000110100001000000110110011101111111001011010010 sub65=10001111110101001101010001010110100011100111100110010111100001010 umul65=0100100001111101011001101100011000101011001110111110000111100100100101110111001100110000100000010011101101111110110100000111111000 smul65=1111011001011100110010100110110101100100110110101011000011110010100101110111001100110000100000010011101101111110110100000111111000
    2 c=10111010111010001101110011100000111101001010110001101110000101101 d=00011010010100101110101000111111010111110101011010100101001000110 add65=11010101001110111100011100100000010101000000001100010011001110011 sub65=10100000100101011111001010100001100101010101010111001000111100111 umul65=0001001100111000001100000000110010110111101101111000101000101110101100011101011000000111110001010110101110010110100011011001001110 smul65=1111100011100101010001011100110101011000011000001110010100001011101100011101011000000111110001010110101110010110100011011001001110
    |}]
;;

(* A hash of every input and output of all 200 cycles. *)
let%expect_test "all cycles" =
  let digest = ref 0 in
  List.iter
    (List.iter (fun (name, value) ->
       String.iter
         (fun ch -> digest := ((!digest * 33) + Char.code ch) land 0xffffff)
         (name ^ value)))
    (Lazy.force rows);
  Printf.printf "cycles=%d digest=%d\n" (List.length (Lazy.force rows)) !digest;
  [%expect {| cycles=200 digest=2522338 |}]
;;
