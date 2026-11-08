DUNE := opam exec -- dune

default:
	$(DUNE) build @install

test:
	$(DUNE) build @lib/runtest @test/arith/runtest @test/js/runtest

promote:
	$(DUNE) promote

clean:
	$(DUNE) clean

.PHONY: default test promote clean
