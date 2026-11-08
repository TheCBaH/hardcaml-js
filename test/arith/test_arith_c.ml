(* Native only: the C stubs against the pure OCaml implementation, and both against Zarith
   where the operation has a plain integer meaning. *)

open Arith_cases
module Bits_arith = Hardcaml.Bits_arith

let to_z s = Z.of_bits s

let expected case =
  let a = to_z case.a
  and b = to_z case.b in
  let signed z w = Z.signed_extract z 0 w in
  match case.op with
  | Add -> Z.extract (Z.add a b) 0 case.width_a
  | Sub -> Z.extract (Z.sub a b) 0 case.width_a
  | Umul -> Z.extract (Z.mul a b) 0 (case.width_a + case.width_b)
  | Smul ->
    Z.extract
      (Z.mul (signed a case.width_a) (signed b case.width_b))
      0
      (case.width_a + case.width_b)
;;

let%expect_test "C stubs, OCaml and Zarith agree" =
  reset ();
  let failures = ref 0
  and oracle_cases = ref 0 in
  let fail case message =
    incr failures;
    if !failures <= 20 then Printf.printf "FAIL %s: %s\n" case.name message
  in
  iter (fun case ->
    let c_buffers, c_result = case.run (module Bits_arith.C) in
    let ((o_buffers, o_result) as o) = case.run (module Bits_arith.Ocaml) in
    if c_result <> o_result || not (Array.for_all2 Bytes.equal c_buffers o_buffers)
    then fail case "C and OCaml differ";
    if case.oracle
    then (
      incr oracle_cases;
      if not (Z.equal (to_z c_result) (expected case))
      then fail case "result differs from Zarith");
    add_digest case.op o);
  Printf.printf "zarith-checked=%d failures=%d\n" !oracle_cases !failures;
  print_digests ();
  [%expect {|
    zarith-checked=6810 failures=0
    add  cases=1364 digest=8430053
    sub  cases=1364 digest=1637758
    umul cases=11644 digest=13956332
    smul cases=11776 digest=11219830
    |}]
;;
