OCAMLMAKEFILE = ../OCamlMakefile

SOURCES = \
  type.ml \
  parser.mly \
  lexer.mll \
  pre_sexp.ml \
  sexp_intf.ml \
  sexp.mli sexp.ml \
  path.mli path.ml \
  conv.mli conv.ml \
  conv_error.ml
LIB_PACK_NAME = sexplib
INCDIRS = +camlp4
OCAMLFLAGS = -for-pack Sexplib
PACKS = type-conv
RESULT = sexplib

TRASH = pa_sexp_conv.cmi pa_sexp_conv.cmo pa_sexp_conv.annot

all: \
	pack-byte-code pack-native-code \
	sexplib.cma sexplib.cmxa \
	pa_sexp_conv.cmi pa_sexp_conv.cmo

LIBINSTALL_FILES = \
  sexp.mli path.mli conv.mli \
  sexplib.cmi sexplib.cma sexplib.cmxa sexplib.a \
  pa_sexp_conv.cmi pa_sexp_conv.cmo

install:	libinstall
uninstall:	libuninstall

clean::	clean-doc

-include $(OCAMLMAKEFILE)
