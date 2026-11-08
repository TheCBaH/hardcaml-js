(** Multiword add, subtract and multiply over little-endian 64-bit words stored in
    [Bytes.t]. These are the only operations of [Bits] and [Bits_packed] that Hardcaml
    implements in C. Results are masked to the destination width. *)

module type S = sig
  type t = Bits0.t

  (** Operands use the [Bits.t] layout: an 8-byte width header followed by the words. The
      width of [add] and [sub] is that of [dst]; for [umul] and [smul] it is the sum of
      the widths of [a] and [b]. [dst] may alias [a] or [b]. *)

  val add : t -> t -> t -> unit
  val sub : t -> t -> t -> unit
  val umul : t -> t -> t -> unit
  val smul : t -> t -> t -> unit

  (** Operands share one buffer without headers; addresses are in 64-bit words. *)
  module Packed : sig
    type op2_width :=
      Bytes.t
      -> dst_address:int
      -> src_address_a:int
      -> src_address_b:int
      -> width_in_bits:int
      -> unit

    type op2_mul :=
      Bytes.t
      -> dst_address:int
      -> src_address_a:int
      -> src_address_b:int
      -> width_in_bits_a:int
      -> width_in_bits_b:int
      -> unit

    val add : op2_width
    val sub : op2_width
    val umul : op2_mul
    val smul : op2_mul
  end
end
