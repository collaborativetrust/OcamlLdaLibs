OUR_LD_ADD = str.cma unix.cma 
OUR_OPTLD_ADD = str.cmxa unix.cmxa 
INCLUDES = 

OCAMLC=ocamlc
OCAMLOPT=ocamlopt
OCAMLMKTOP=ocamlmktop

OCAMLLEX=ocamllex
OCAMLYACC=ocamlyacc
OCAMLDEP=ocamldep
OCAMLMKLIB=ocamlmklib
OCAMLDOC=ocamldoc
OCAMLFIND_C=ocamlfind ocamlcp
OCAMLFIND_COPT=ocamlfind ocamlopt

SUFFIXES= .ml .cmo .cmi .cmx

# OCAMLDEBUG = -g -p film 
OCAMLDEBUG = -g

# Flags for commands, depending on optimization/debugging, and db/non-db
OCAML_CFLAGS=$(INCLUDES) $(OCAMLDEBUG)
OCAMLOPT_FLAGS=$(INCLUDES) 

%.cmo: %.ml
	@echo '$(OCAMLC) $(OCAML_CFLAGS) -c $<'; \
	$(OCAMLC) $(OCAML_CFLAGS) -c $<

%.cmi: %.mli
	@echo '$(OCAMLC) $(OCAML_CFLAGS) -c $<'; \
	$(OCAMLC) $(OCAML_CFLAGS) -c $<

%.cmx: %.ml
	@echo '$(OCAMLOPT) $(OCAMLOPT_FLAGS) -c $<'; \
	$(OCAMLOPT) $(OCAMLOPT_FLAGS) -c $<

.PHONY: all clean


# Objects

vec: vec.cmo
vecopt: vec.cmx

mapmin: mapmin.cmo
mapminopt: mapmin.cmx

intvmap: intvmap.cmo
intvmapopt: intvmap.cmx

hashtbl_bounded: hashtbl_bounded.cmo
hashtbl_boundedopt: hashtbl_bounded.cmx

all: vec.cmo mapmin.cmo intvmap.cmo hashtbl_bounded.cmo

allopt: vec.cmx mapmin.cmx intvmap.cmx hashtbl_bounded.cmx

clean:
	rm -f *.o *.cmo *.cmx *.cmi .depends 

.depends: *.ml
	$(OCAMLDEP) $^ > $@

-include .depends
