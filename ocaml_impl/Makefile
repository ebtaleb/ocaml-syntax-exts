OCAMLBUILD = ocamlbuild

# OPAM repository
OPREP = $(OCAML_TOPLEVEL_PATH)/..
#~/.opam/system/lib
BATLIB = batteries/batteries
ELIB = extlib/extLib
GRLIB = ocamlgraph/graph
OLIBS = $(OPREP)/$(GRLIB),
#CPPO_FLAGS = -pp "cppo -I ../ -D TRACE"
CPPO_FLAGS =

#CFLAGS1='-Wl,--rpath=/usr/lib-2.12'
#CFLAGS2='-Wl,--dynamic-linker=/usr/lib-2.12/ld-linux.so.2'

ifdef OCAML_TOPLEVEL_PATH
 INCLPRE = $(OPREP)
 LIBBATLIB = $(OPREP)/$(BATLIB)
 LIBELIB = $(OPREP)/$(ELIB)
 LIBGLIB = $(OPREP)/$(GRLIB)
 LIBIGRAPH = $(OPREP)/ocamlgraph
else
 INCLPRE = +site-lib
 LIBBATLIB = site-lib/$(BATLIB)
 LIBELIB = site-lib/$(ELIB)
 LIBGLIB = graph
 LIBIGRAPH = +ocamlgraph
endif

#  number of parallel jobs, 0 means unlimited.
JOBS = 16

# dynlink should precede camlp4lib
LIBSB = unix,str,dynlink,camlp4lib,nums,$(LIBBATLIB),$(LIBELIB),$(LIBGLIB)
LIBSN = unix,str,dynlink,camlp4lib,nums,$(LIBBATLIB),$(LIBELIB),$(LIBGLIB)
#,z3
# LIBS2 = unix,str,ablgtk,lablgtksourceview2,dynlink,camlp4lib

INCLUDES = -I,+camlp4,-I,$(INCLPRE)/batteries,-I,$(INCLPRE)/extlib,-I,$(LIBIGRAPH)
INCLUDESN = -I,$(INCLPRE)/batteries,-I,$(INCLPRE)/extlib,-I,$(LIBIGRAPH)

PROPERERRS = -warn-error,+4+8+9+11+12+25+28

#FLAGS = $(INCLUDES),-g,-annot,-ccopt,-fopenmp
FLAGS = $(INCLUDES),$(PROPERERRS),-annot,-ccopt,-fopenmp #,-ccopt,CFLAGS1,-ccopt,CFLAGS2

GFLAGS = $(INCLUDES),-g,-annot,-ccopt,-fopenmp
SCFLAGS = $(INCLUDES),$(PROPERERRS),-annot,-ccopt,-fopenmp #-ccopt,-static,-ccopt,-fPIE
SLFLAGS = $(INCLUDES),$(PROPERERRS),-annot,-ccopt,-static,-ccopt,-fopenmp #,-ccopt,-pie #,-ccopt,-pic
#FLAGS = $(INCLUDES),-ccopt,-fopenmp
#GFLAGS = $(INCLUDES),-g,-ccopt,-fopenmp
#GFLAGS = $(INCLUDES),$(PROPERERRS),-g,-annot,-ccopt,-fopenmp
# ,-cclib,-lz3stubs,-cclib,-lz3,/usr/local/lib/ocaml/libcamlidl.a

# -no-hygiene flag to disable "hygiene" rules
OBB_GFLAGS = -no-links -libs $(LIBSB) -cflags $(GFLAGS) -lflags $(GFLAGS) -lexflag -q -yaccflag -v  -j $(JOBS)  $(CPPO_FLAGS)
OBB_NGFLAGS = -no-links -libs $(LIBSB) -cflags $(GFLAGS) -lflags $(GFLAGS) -lexflag -q -yaccflag -v  -j $(JOBS)

OBB_FLAGS = -no-links -libs $(LIBSB) -cflags $(FLAGS) -lflags $(FLAGS) -lexflag -q -yaccflag -v  -j $(JOBS) $(CPPO_FLAGS)
OBN_FLAGS = -no-links -libs $(LIBSN) -cflags $(FLAGS) -lflags $(FLAGS) -lexflag -q -yaccflag -v  -j $(JOBS) $(CPPO_FLAGS)

#static - incl C libs
OBNS_FLAGS = -no-links -libs $(LIBSN) -cflags $(SCFLAGS) -lflags $(SLFLAGS) -lexflag -q -yaccflag -v  -j $(JOBS) $(CPPO_FLAGS)

#pr0.byte: pr0.byte

all: pr0.byte pr1.byte pr2.byte pr3.byte pr4.byte

%.byte: %.ml
	@ocamlbuild $(OBB_GFLAGS) $*.byte
	cp -pu _build/$@ $*

# Clean up
clean:
	$(OCAMLBUILD) -quiet -clean
	rm -f *.cmo *.cmi *.cmx *.o *.mli *.output *.annot slexer.ml ilexer.ml lexer.ml iparser.ml oclexer.ml ocparser.ml rlparser.ml rllexer.ml *.depends pr0 pr1 pr2 pr3 pr4 __tmp
#	rm -f iparser.mli iparser.ml iparser.output oc.out

