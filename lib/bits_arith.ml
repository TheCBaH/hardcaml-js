module type S = Bits_arith_intf.S

module Ocaml = Bits_arith_ocaml

module C = struct
  type t = Bits0.t

  external add_stub : Bits0.t -> Bits0.t -> Bits0.t -> unit = "hardcaml_bits_add"
  [@@noalloc]

  external sub_stub : Bits0.t -> Bits0.t -> Bits0.t -> unit = "hardcaml_bits_sub"
  [@@noalloc]

  external umul_stub : Bits0.t -> Bits0.t -> Bits0.t -> unit = "hardcaml_bits_umul"
  [@@noalloc]

  external smul_stub : Bits0.t -> Bits0.t -> Bits0.t -> unit = "hardcaml_bits_smul"
  [@@noalloc]

  let add = add_stub
  let sub = sub_stub

  let umul dst a b =
    umul_stub dst a b;
    Ocaml.mask (dst :> Bytes.t) ~address:1 ~width:(Ocaml.header_width (dst :> Bytes.t))
  ;;

  let smul dst a b =
    smul_stub dst a b;
    Ocaml.mask (dst :> Bytes.t) ~address:1 ~width:(Ocaml.header_width (dst :> Bytes.t))
  ;;

  module Packed = struct
    external add
      :  Bytes.t
      -> dst_address:int
      -> src_address_a:int
      -> src_address_b:int
      -> width_in_bits:int
      -> unit
      = "hardcaml_bits_packed_add"
    [@@noalloc]

    external sub
      :  Bytes.t
      -> dst_address:int
      -> src_address_a:int
      -> src_address_b:int
      -> width_in_bits:int
      -> unit
      = "hardcaml_bits_packed_sub"
    [@@noalloc]

    external umul_stub
      :  Bytes.t
      -> dst_address:int
      -> src_address_a:int
      -> src_address_b:int
      -> width_in_bits_a:int
      -> width_in_bits_b:int
      -> unit
      = "hardcaml_bits_packed_umul_bc" "hardcaml_bits_packed_umul"
    [@@noalloc]

    external smul_stub
      :  Bytes.t
      -> dst_address:int
      -> src_address_a:int
      -> src_address_b:int
      -> width_in_bits_a:int
      -> width_in_bits_b:int
      -> unit
      = "hardcaml_bits_packed_smul_bc" "hardcaml_bits_packed_smul"
    [@@noalloc]

    let umul t ~dst_address ~src_address_a ~src_address_b ~width_in_bits_a ~width_in_bits_b =
      umul_stub t ~dst_address ~src_address_a ~src_address_b ~width_in_bits_a ~width_in_bits_b;
      Ocaml.mask t ~address:dst_address ~width:(width_in_bits_a + width_in_bits_b)
    ;;

    let smul t ~dst_address ~src_address_a ~src_address_b ~width_in_bits_a ~width_in_bits_b =
      smul_stub t ~dst_address ~src_address_a ~src_address_b ~width_in_bits_a ~width_in_bits_b;
      Ocaml.mask t ~address:dst_address ~width:(width_in_bits_a + width_in_bits_b)
    ;;
  end
end

type t = Bits0.t

let native =
  match Sys.backend_type with
  | Native | Bytecode -> true
  | Other _ -> false
;;

let add = if native then C.add else Ocaml.add
let sub = if native then C.sub else Ocaml.sub
let umul = if native then C.umul else Ocaml.umul
let smul = if native then C.smul else Ocaml.smul

module Packed = struct
  let add = if native then C.Packed.add else Ocaml.Packed.add
  let sub = if native then C.Packed.sub else Ocaml.Packed.sub
  let umul = if native then C.Packed.umul else Ocaml.Packed.umul
  let smul = if native then C.Packed.smul else Ocaml.Packed.smul
end
