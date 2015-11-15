all: ppx_test.native

ppx_test.native:
	ocamlbuild -package compiler-libs.common ppx_test.native

run: ppx_test.native
	@ocamlc -dsource -ppx ./ppx_test.native ws0.ml
