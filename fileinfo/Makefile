OCAMLC=ocamlc -I xml-light
OCAMLOPT=ocamlopt -I xml-light
OCAMLMKTOP=ocamlmktop

OCAMLDEP=ocamldep
OCAMLMKLIB=ocamlmklib
OCAMLDOC=ocamldoc
OCAMLFIND_C=ocamlfind ocamlc
OCAMLFIND_COPT=ocamlfind ocamlopt

INSTALLDIR=`ocamlc -where`
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

ALLCMO = xml-light/xml_parser.cmo xml-light/xml_lexer.cmo xml-light/dtd.cmo xml-light/xmlParser.cmo xml-light/xml.cmo fileinfo.cmo 
ALLCMX = xml-light/xml_parser.cmx xml-light/xml_lexer.cmx xml-light/dtd.cmx xml-light/xmlParser.cmx xml-light/xml.cmx fileinfo.cmx 

all: 
	cd xml-light; make all; make allopt
	make allnor
	make allopt

install: 
	ocamlfind install -destdir $(INSTALLDIR) fileinfo META fileinfo.cma fileinfo.cmxa fileinfo.a fileinfo.mli fileinfo.ml fileinfo.cmi

uninstall:
	ocamlfind remove -destdir $(INSTALLDIR) fileinfo

allnor: 
	make mk_allcmo
	$(OCAMLC) $(OCAML_CFLAGS) -a -o fileinfo.cma $(ALLCMO) 

allopt: 
	make mk_allcmx
	$(OCAMLOPT) $(OCAMLOPT_FLAGS) -a -o fileinfo.cmxa $(ALLCMX)

mk_allcmo: $(ALLCMO)
mk_allcmx: $(ALLCMX)

clean:
	rm -f *.o *.a *.cmo *.cmx *.cma *.cmxa *.cmi .depends 

.depends: *.ml
	$(OCAMLDEP) $^ > $@

-include .depends
