OUR_LD_ADD = str.cma unix.cma xml-light.cma 
OUR_OPTLD_ADD = str.cmxa unix.cmxa xml-light.cmxa
INCLUDES = -I xml-light -I vec -I mapmin -I intvmap -I hashtbl_bounded -I fileinfo

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

ALLCMO = vec/vec.cmo mapmin/mapmin.cmo intvmap/intvmap.cmo hashtbl_bounded/hashtbl_bounded.cmo fileinfo/fileinfo.cmo
ALLCMX = vec/vec.cmx mapmin/mapmin.cmx intvmap/intvmap.cmx hashtbl_bounded/hashtbl_bounded.cmx fileinfo/fileinfo.cmx

## We need this seperately because it is a requirement for sexplib, and needs to be installed
#  before sexplib can be built.

typeconv: 
	cd type-conv; make uninstall; make all; make install

all: 
	cd xml-light; make all;  make allopt
	cd sexplib; make all; 
	make mk_allcmx
	make mk_allcmo
	$(OCAMLC) $(OCAML_CFLAGS) -a -o ocamlldalibs.cma $(ALLCMO)
	$(OCAMLOPT) $(OCAMLOPT_FLAGS) -a -o ocamlldalibs.cmxa $(ALLCMX)

install:
	cd sexplib; make install
	cd xml-light; make install
	ocamlfind install ocamlldalibs META ocamlldalibs.* vec/vec.cm* mapmin/mapmin.cm* intvmap/intvmap.cm* hashtbl_bounded/hashtbl_bounded.cm* fileinfo/fileinfo.cm*
	#cd vec; ocamlfind install vec META vec.cmi vec.cmo vec.cmx
	#cd mapmin; ocamlfind install mapmin META mapmin.cmi mapmin.cmo mapmin.cmx
	#cd intvmap; ocamlfind install intvmap META intvmap.cmi intvmap.cmo intvmap.cmx
	#cd hashtbl_bounded; ocamlfind install hashtbl_bounded META hashtbl_bounded.cmi hashtbl_bounded.cmo hashtbl_bounded.cmx
	#cd fileinfo; ocamlfind install fileinfo META fileinfo.cmi fileinfo.cmo fileinfo.cmx

uninstall:
	cd type-conv; make uninstall
	cd sexplib; make uninstall
	ocamlfind remove ocamlldalibs
	#ocamlfind remove vec
	#ocamlfind remove mapmin
	#ocamlfind remove intvmap
	#ocamlfind remove hashtbl_bounded
	#ocamlfind remove fileinfo

mk_allcmo: $(ALLCMO)
mk_allcmx: $(ALLCMX)

vec: vec/vec.cmo
vecopt: vec/vec.cmx

mapmin: mapmin/mapmin.cmo
mapminopt: mapmin/mapmin.cmx

intvmap: intvmap/intvmap.cmo
intvmapopt: intvmap/intvmap.cmx

hashtbl_bounded: hashtbl_bounded/hashtbl_bounded.cmo
hashtbl_boundedopt: hashtbl_bounded/hashtbl_bounded.cmx

fileinfo: fileinfo/fileinfo.cmo
fileinfoopt: fileinfo/fileinfo.cmx

clean:
	rm -f */*.o */*.cmo */*.cmx */*.cmi *.a *.cma *.cmxa .depends 
	cd xml-light; make clean
	cd type-conv; make clean
	cd sexplib; make clean

.depends: */*.ml
	$(OCAMLDEP) $^ > $@

-include .depends
