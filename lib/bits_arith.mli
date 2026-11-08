(** Multiword add, subtract and multiply used by [Bits] and [Bits_packed].

    Native and bytecode use the C stubs in [bits_stubs.c]; every other backend (js_of_ocaml,
    Melange) uses the pure OCaml implementation. *)

module type S = Bits_arith_intf.S

(** The C stubs. Calling them on a non-native backend fails. *)
module C : S

(** Pure OCaml on 16-bit limbs. Always available, and used for differential testing
    against {!C}. *)
module Ocaml : S

include S with type t = Bits0.t
