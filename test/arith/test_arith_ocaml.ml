(* The pure OCaml implementation: runs natively and under js_of_ocaml against the same
   expectation. *)

open Arith_cases

let%expect_test "pure OCaml add, sub, umul and smul" =
  reset ();
  iter (fun case -> add_digest case.op (case.run (module Hardcaml.Bits_arith.Ocaml)));
  print_digests ();
  [%expect {|
    add  cases=1364 digest=8430053
    sub  cases=1364 digest=1637758
    umul cases=11644 digest=13956332
    smul cases=11776 digest=11219830
    |}]
;;
