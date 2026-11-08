# hardcaml-js

[![build](https://github.com/TheCBaH/hardcaml-js/actions/workflows/build.yml/badge.svg?branch=main)](https://github.com/TheCBaH/hardcaml-js/actions/workflows/build.yml)
[![images](https://github.com/TheCBaH/hardcaml-js/actions/workflows/images.yml/badge.svg?branch=main)](https://github.com/TheCBaH/hardcaml-js/actions/workflows/images.yml)

[Hardcaml](https://github.com/janestreet/hardcaml) v0.17.1 built from an unmodified git
submodule (`hardcaml/`, pinned to the `v0.17.1` tag), with a few substitutions applied by
dune so that it also runs under js_of_ocaml (and, in principle, Melange).

This repository does not contain Hardcaml's sources or history.

## Get started

* [![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://github.com/codespaces/new?hide_repo_select=true&ref=main&repo=1449888826)
* run `make test`

## How it works

- `lib/` is the `hardcaml` library. `lib/gen/gen.ml` lists the files of `hardcaml/src`;
  `lib/dune.inc` has one rule per file: a copy, or the file with `lib/patches/<file>.patch`
  applied when such a patch exists. `dune runtest` fails if `dune.inc` is stale
  (`dune promote` fixes it after a submodule bump).
- `lib/bits_arith*.ml` is new: add, sub, umul and smul (and the packed variants) behind one
  module. Native and bytecode call the unchanged C stubs; other backends use a pure OCaml
  implementation on 16-bit limbs (no `Int64`, no 63-bit `int`). The patches make `Bits` and
  `Bits_packed` call it and export `Hardcaml.Bits_arith`.
- `ppx/` copies Hardcaml's `ppx_hardcaml0` from the submodule.
- `zarith_stubs_js` is linked so Zarith works under js_of_ocaml.
- The submodule directory is a `data_only_dirs`, so dune never builds its own stanzas.

## Tests

`make test` runs expect tests (ppx_expect), so the output of every test is visible in the
source; `make promote` accepts a changed output.

- `test/arith`: the C stubs against the pure OCaml implementation and Zarith, widths 1 to 321
  (including 31–33, 63–65, 128 and odd sizes), signed and unsigned, with overlapping
  destinations in packed buffers (native only). The pure OCaml implementation runs
  natively and under js_of_ocaml against the same expected case counts and digests.
- `test/js`: Cyclesim of a counter, an enabled register, a synchronous RAM and 33/65-bit
  arithmetic. The trace is printed and runs natively and under js_of_ocaml against the
  same expectation.

MIT licensed (`LICENSE.md`). Hardcaml itself is Copyright Jane Street Group, LLC, MIT; see `NOTICE`.
