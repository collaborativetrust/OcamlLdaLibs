OUR_LD_ADD = str.cma unix.cma xml-light.cma 
OUR_OPTLD_ADD = str.cmxa unix.cmxa xml-light.cmxa
INCLUDES = -I xml-light

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

ALLCMO = vec.cmo mapmin.cmo intvmap.cmo hashtbl_bounded.cmo fileinfo.cmo
ALLCMX = vec.cmx mapmin.cmx intvmap.cmx hashtbl_bounded.cmx fileinfo.cmx

all: 
	cd xml-light; make all
	cd type-conv; make all; make install
	cd sexplib; make all; make install
	make mk_allcmo
	$(OCAMLC) $(OCAML_CFLAGS) -a -o ocamlldalibs.cma $(ALLCMO) 

allopt: 
	cd xml-light; make allopt
	cd type-conv; make all; make install
	cd sexplib; make all; make install
	make mk_allcmx
	$(OCAMLOPT) $(OCAMLOPT_FLAGS) -a -o ocamlldalibs.cmxa $(ALLCMX)

mk_allcmo: $(ALLCMO)
mk_allcmx: $(ALLCMX)

vec: vec.cmo
vecopt: vec.cmx

mapmin: mapmin.cmo
mapminopt: mapmin.cmx

intvmap: intvmap.cmo
intvmapopt: intvmap.cmx

hashtbl_bounded: hashtbl_bounded.cmo
hashtbl_boundedopt: hashtbl_bounded.cmx

fileinfo: fileinfo.cmo
fileinfoopt: fileinfo.cmx

clean:
	rm -f *.o *.cmo *.cmx *.cmi .depends 
	cd xml-light; make clean
	cd type-conv; make clean
	cd sexplib; make clean

.depends: *.ml
	$(OCAMLDEP) $^ > $@

-include .depends
