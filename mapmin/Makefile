OCAMLC=ocamlc
OCAMLOPT=ocamlopt
OCAMLMKTOP=ocamlmktop

OCAMLDEP=ocamldep
OCAMLMKLIB=ocamlmklib
OCAMLDOC=ocamldoc
OCAMLFIND_C=ocamlfind ocamlc
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

ALLCMO = mapmin.cmo
ALLCMX = mapmin.cmx

all: 
	make allnor
	make allopt

install: 
	ocamlfind install mapmin META mapmin.cma mapmin.cmxa mapmin.a mapmin.mli mapmin.ml mapmin.cmi

uninstall:
	ocamlfind remove mapmin

allnor: 
	make mk_allcmo
	$(OCAMLC) $(OCAML_CFLAGS) -a -o mapmin.cma $(ALLCMO) 

allopt: 
	make mk_allcmx
	$(OCAMLOPT) $(OCAMLOPT_FLAGS) -a -o mapmin.cmxa $(ALLCMX)

mk_allcmo: $(ALLCMO)
mk_allcmx: $(ALLCMX)

clean:
	rm -f *.o *.a *.cmo *.cmx *.cma *.cmxa *.cmi .depends 

.depends: *.ml
	$(OCAMLDEP) $^ > $@

-include .depends
