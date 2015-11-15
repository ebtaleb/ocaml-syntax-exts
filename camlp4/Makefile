OCAMLC=ocamlc.opt
OCAMLOPT=ocamlopt.opt
OCAMLDEP=ocamldep
OCAMLDOC=ocamldoc
DIRS=.
INCLUDES=-annot dynlink.cma -I +camlp4 camlp4lib.cma -pp camlp4of.opt
GUIINCLUDES=-I +lablgtk2
OCAMLFLAGS=  $(INCLUDES) # add other options for ocamlc here
GUIOCAMLFLAGS= $(OCAMLFLAGS) $(GUIINCLUDES) #
OCAMLOPTFLAGS= -dtypes $(INCLUDES) # add other options for ocamlopt here

all: bin

bin:
	@ocamlc $(INCLUDES) -o ed -g test.ml 2> /dev/null

ws0-code: bin
	@./ed ws0.ml

ws1-code: bin
	@./ed ws1.ml

ws2-code: bin
	@./ed ws2.ml

ws3-code: bin
	@./ed ws3.ml

ws4-code: bin
	@./ed ws4.ml

run-ws0:
	@./ed ws0.ml > ws0_ex.ml
	@cat base.ml ws0_ex.ml > final.ml
	@ocamlc final.ml
	@./a.out

run-ws1:
	@./ed ws1.ml > ws1_ex.ml
	@cat base.ml ws1_ex.ml > final.ml
	@ocamlc final.ml
	@./a.out

run-ws2:
	@./ed ws2.ml > ws2_ex.ml
	@cat base.ml ws2_ex.ml > final.ml
	@ocamlc final.ml
	@./a.out

run-ws3:
	@./ed ws3.ml > ws3_ex.ml
	@cat base.ml ws3_ex.ml > final.ml
	@ocamlc final.ml
	@./a.out

run-ws4:
	@./ed ws4.ml > ws4_ex.ml
	@cat base.ml ws4_ex.ml > final.ml
	@ocamlc final.ml
	@./a.out

.SUFFIXES: .ml .mli .cmo .cmi .cmx .mly .mll

.ml.annot:
	$(OCAMLC) $(OCAMLFLAGS) -c -g $<

.ml.cmo:
	$(OCAMLC) $(OCAMLFLAGS) -c -g $<

.mli.cmi:
	$(OCAMLC) $(OCAMLFLAGS) -c -g $<

.ml.cmx:
	$(OCAMLOPT) $(OCAMLOPTFLAGS) -c $<

clean:
	rm *.cmo *.cmi *.annot ed final.ml a.out ws0_ex.ml ws1_ex.ml ws2_ex.ml ws3_ex.ml ws4_ex.ml tmp
