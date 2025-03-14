#	This file is part of the software similarity tester SIM.
#	Written by Dick Grune, VU, Amsterdam; dick@dickgrune.com
#	$Id: Makefile,v 2.125 2024-02-07 20:52:34 dick Exp $
#

VERSION="-DVERSION=\"3.0.5-2 of 2025-03-14\""	# uncomment for public version

#	E N T R Y   P O I N T S

help:
	@echo  'Entry points:'
	@echo  'test:           compile sim_c and run a simple test'
	@echo  ''
	@echo  'binaries:       create all binaries'
	@echo  'exes:           create executables in MSDOS'
	@echo  'install:        install all binaries'
	@echo  ''
	@echo  'view_man:       view sim.pdf'
	@echo  'lint:           lint sim sources'
	@echo  'simsim:         run sim_c on the sim sources'
	@echo  'view_SPC:       view the percentage computation document'
	@echo  'chklat:         do a LaTeX check on the .tex documents'
	@echo  ''
	@echo  'fresh:          remove created files'

#
# When you modify any of the following macros, do 'make clean'
#

# System dependencies
#	=============== including ../../lib/sysidf.mk here
#	This file is part of the auxiliary libraries.
#	Written by Dick Grune, dick@dickgrune.com
#	$Id: sysidf.mk,v 1.22 2024-02-07 20:52:34 dick Exp $
#
# There is a UNIX-like section, an MSDOS section and a general section.
# For UNIX-like systems, delete the MSDOS section below.

################################################################
# For UNIX-like systems

SYSTEM =	UNIX

# Locations
PREFIX =	/usr/local
BINDIR =	$(PREFIX)/bin
MANDIR =	$(PREFIX)/man
MAN1DIR =	$(MANDIR)/man1

# Commands
COPY =		install
#COPY =		cp -p
EXE =		#
LEX =		flex
LN =		ln
ZIP =		zip -o
GROFF =		groff -man

# File names
NULLFILE =	/dev/null

################################################################
# For MSDOS + MinGW

#SYSTEM =	MSDOS

# Locations
#DIR =		C:/BIN
#BINDIR =	C:/BIN
#MAN1DIR =	C:/BIN

# File names
#NULLFILE =	nul

# Commands (cp required, since xcopy cannot handle forward slashes)
#COPY =		cp -p
#EXE =		.exe
#LEX =		flex
#LN =		ln
#ZIP =		zip -o
#GROFF =		man2pdf

################################################################
# General, C compilation:
CC =		gcc -D$(SYSTEM)
#CC =		gcc -D$(SYSTEM) $(GCC_FULL_WARN)
#CC =		clang -D$(SYSTEM)
LINT =		lint -ansi -D$(SYSTEM)
LINTFLAGS =	-xh

# General, text:
LATEX =		pdflatex
#VIEW_PDF =	pdfview #		# any PDF viewer will do
VIEW_PDF =	okular

.SUFFIXES:	.1 .3 .pdf

.1.pdf:
		ps2pdf <($(GROFF) sim.1) $@

.3.pdf:
		$(GROFF) $<
#	=============== end of ../../lib/sysidf.mk

# Compiling
#export DEB_BUILD_MAINT_OPTIONS=hardening=+all
GCC_FULL_WARN	= -Wall -Wpointer-arith -Wcast-qual -Wwrite-strings -ffast-math -fno-unsafe-math-optimizations \
		-Wdeclaration-after-statement -Wclobbered -Wempty-body -Wignored-qualifiers -Wmissing-parameter-type \
		-Wmissing-field-initializers -Wold-style-declaration -Wtype-limits -Wuninitialized -Winit-self -Wextra \
		-Wredundant-decls -Wparentheses -Wunused-parameter -Wunused-variable -Wunused-function -Wunused-value \
		-Wswitch-default -Wreturn-type -Wlogical-op -Wshadow -Wmissing-variable-declarations -Walloc-zero \
		-Wcalloc-transposed-args -Wduplicated-branches -Wformat-security -Wformat-y2k -Wnull-dereference \
		-Wswitch-enum -Wunused-const-variable -Wjump-misses-init -Wstrict-prototypes -Wduplicated-cond \
		-Wundef -Wunused-macros -Wcast-align -Wpacked -Wmissing-prototypes -Wmissing-declarations -Wnested-externs \
		-Wbad-function-cast -Wconversion -Wno-sign-conversion
MEMORY =	-DMEMCHECK -DMEMCLOBBER
CFLAGS =	$(VERSION) $(MEMORY) -Ofast # $(GCC_FULL_WARN) # -Dlint -DLIB # for all db active
#CFLAGS =	$(VERSION) $(MEMORY) -O4  $(shell dpkg-buildflags --get CPPFLAGS) $(shell dpkg-buildflags --get CFLAGS) -fPIC
LIBFLAGS =	#
LINTFLAGS =	-Dlint_test $(MEMORY) -h# -X
LOADFLAGS =	-s#			# strip symbol table
#LOADFLAGS =	-s $(shell dpkg-buildflags --get LDFLAGS) # strip symbol table
LOADER =	$(CC) $(LOADFLAGS)

# Debugging
CFLAGS +=	-DDEBUG

#	T E S T   P A R A M E T E R S

# Rumen Stevanov test
TEST_LANG =	text
TEST_FLAGS =	-pPae -r4 -O -t4
TEST_INPUT =	Contributors/Rumen_Stefanov/new/*.txt

# slash test
TEST_LANG =	text
TEST_FLAGS =	-r24 -M clang.l pasclang.l "|" textlang.l
TEST_INPUT =

# -i option test
TEST_LANG =	c
TEST_FLAGS =	-f -r 20 -R -i <option-i.inp
TEST_INPUT =	#

# overlap  test, foo^100 vs. foo^150
TEST_LANG =	text
TEST_FLAGS =	-r50 -p
TEST_FLAGS =	-r50
TEST_INPUT =	Test_percentages/foo_100
TEST_INPUT =	Test_percentages/foo_100 Test_percentages/foo_150

# single file test
TEST_LANG =	c
TEST_FLAGS =	-r24 -M
TEST_INPUT =	pass3.c pass3.c	# compares 1st to 2nd, then 2nd to 2nd

# tight match test, foo_100 has exactly 100 tokens
TEST_LANG =	text
TEST_FLAGS =	-r50
TEST_INPUT =	Test_percentages/foo_100

# percentage test
TEST_LANG =	c
TEST_FLAGS =	-puae
TEST_INPUT =	*.l

# spaced word test
TEST_LANG =	text
TEST_FLAGS =	-r 5
TEST_INPUT =	Testfiles/test_seplet

# larger test
TEST_LANG =	text
TEST_FLAGS =	-r24 -M -puae
TEST_INPUT = clang.c textlang.c
TEST_INPUT = textlang.c clang.c javalang.c

# test UTF-8 file names
TEST_LANG =	text
TEST_FLAGS =	Kor_test/한국어 Kor_test/한국어# 'make' cannot see these files
TEST_INPUT =	#

# test UTF-8 recursive file name test
TEST_LANG =	text
TEST_FLAGS =	-R Kor_test
TEST_INPUT =	#

# test bad UTF-8 text
TEST_LANG =	text
TEST_FLAGS =	-r12 -MO -w80
TEST_INPUT =	Testfiles/Korean1_bad.txt Testfiles/Korean1_bad2.txt

# test UTF-8 text
TEST_LANG =	text
TEST_FLAGS =	-r12 -MO -w80
TEST_INPUT =	Testfiles/Korean1.txt Testfiles/Korean2.txt

# test
TEST_LANG =	c
TEST_FLAGS =	-r10 -MO
TEST_INPUT =	pass2.c pass1.c

#TEST_FLAGS =	-h

#	M A I N   M O D U L E S

#	Each module (set of programs that together perform some function)
#	has the following sets of files defined for it:
#		_SRC	the C-files from which the object files derive
#		_OBJ	object files
#		_HDR	header files and other include files
#		_GRB	garbage files produced by the module
#
#	(This is a feeble attempt at software-engineering a Makefile.)
#

test:		sim.res stream.res percentages.res version.res
		./sim_$(TEST_LANG)$(EXE) -v


#	B I N A R I E S

BINARIES =	sim_c$(EXE) sim_c++$(EXE) sim_java$(EXE) sim_pasc$(EXE) sim_php$(EXE) \
		sim_m2$(EXE) sim_lisp$(EXE) sim_mira$(EXE) sim_text$(EXE) \
		sim_8086$(EXE)

binaries:	$(BINARIES)#		# for *N?X
exes:		binaries#		# for MSDOS
test_exes:	binaries#		# for packCVS

#	A U X I L I A R Y   M O D U L E S

# Common modules:
COM_SRC =	global.c token.c lex.c stream.c text.c tokenarray.c debug.c \
		utf8.c ForEachFile.c fname.c Malloc.c any_int.c
COM_OBJ =	global.o token.o lex.o stream.o text.o tokenarray.o debug.o \
		utf8.o ForEachFile.o fname.o Malloc.o any_int.o
COM_HDR =	global.h token.h lex.h stream.h text.h tokenarray.h debug.h \
		utf8.h ForEachFile.h fname.h Malloc.h any_int.h \
		lang.h \
		sortlist.spc sortlist.bdy system.par

# C files for the abstract modules:
ABS_SRC =	lang.c

# The idf module:
IDF_SRC =	idf.c
IDF_OBJ =	idf.o
IDF_HDR =	idf.h

# The runs package:
RUNS_SRC =	runs.c percentages.c
RUNS_OBJ =	runs.o percentages.o
RUNS_HDR =	runs.h percentages.h

# The main program:
MAIN_SRC =	sim.c options.c newargs.c hash.c compare.c add_run.c \
		pass1.c pass2.c pass3.c
MAIN_OBJ =	sim.o options.o newargs.o hash.o compare.o add_run.o \
		pass1.o pass2.o pass3.o
MAIN_HDR =	global.h options.h newargs.h hash.h compare.h add_run.h \
		pass1.h pass2.h pass3.h \
		debug.par settings.par

sim.o:	 	Makefile	# because of $(VERSION)

# The similarity tester without the language part:
SIM_SRC =	$(COM_SRC) $(IDF_SRC) $(RUNS_SRC) $(MAIN_SRC)
SIM_OBJ =	$(COM_OBJ) $(IDF_OBJ) $(RUNS_OBJ) $(MAIN_OBJ)
SIM_HDR =	$(COM_HDR) $(IDF_HDR) $(RUNS_HDR) $(MAIN_HDR)


#	L A N G U A G E S

# The properties module:
PROP_SRC =	properties.c
PROP_OBJ =	properties.o
PROP_HDR =	properties.h

# The Generic Language module
#	variable:	GEN_LANG
#	entry point:	sim_gen$(EXE)
#	makes:		sim_$(GEN_LANG)$(EXE)

sim_gen.c:	$(GEN_LANG)lang.l
		$(LEX) -t $(GEN_LANG)lang.l >sim_gen.c
GEN_GRB +=	sim_gen.c

SIM_GEN_SRC =	$(SIM_SRC) $(PROP_SRC)
SIM_GEN_OBJ =	$(SIM_OBJ) $(PROP_OBJ)

sim_gen$(EXE):	$(SIM_GEN_OBJ)
		$(LOADER) $(SIM_GEN_OBJ) -o $@
		mv sim_gen$(EXE) sim_$(GEN_LANG)$(EXE)
		rm -f sim_gen.[co]

%.c:		%.l $(LEX_HDR)
		$(LEX) -t $< >$@ || (rm -f $@ ; exit 1)

# The executables:

LEX_HDR:	options.h token.h properties.h idf.h lex.h lang.h

sim_c$(EXE):	clang.o $(SIM_GEN_OBJ)
		$(LOADER) clang.o $(SIM_GEN_OBJ) -o $@

sim_text$(EXE):	textlang.o $(SIM_GEN_OBJ)
		$(LOADER) textlang.o $(SIM_GEN_OBJ) -o $@

sim_c++$(EXE):	c++lang.o $(SIM_GEN_OBJ)
		$(LOADER) c++lang.o $(SIM_GEN_OBJ) -o $@

sim_java$(EXE):	javalang.o $(SIM_GEN_OBJ)
		$(LOADER) javalang.o $(SIM_GEN_OBJ) -o $@

sim_pasc$(EXE):	pasclang.o $(SIM_GEN_OBJ)
		$(LOADER) pasclang.o $(SIM_GEN_OBJ) -o $@

sim_php$(EXE):	phplang.o $(SIM_GEN_OBJ)
		$(LOADER) phplang.o $(SIM_GEN_OBJ) -o $@

sim_m2$(EXE):	m2lang.o $(SIM_GEN_OBJ)
		$(LOADER) m2lang.o $(SIM_GEN_OBJ) -o $@

sim_lisp$(EXE):	lisplang.o $(SIM_GEN_OBJ)
		$(LOADER) lisplang.o $(SIM_GEN_OBJ) -o $@

sim_mira$(EXE):	miralang.o $(SIM_GEN_OBJ)
		$(LOADER) miralang.o $(SIM_GEN_OBJ) -o $@

sim_8086$(EXE):	8086lang.o $(SIM_GEN_OBJ)
		$(LOADER) 8086lang.o $(SIM_GEN_OBJ) -o $@


#	T E S T S

# Some simple tests:
.PHONY:		sim.res percentages.res

sim.res:	sim_$(TEST_LANG)$(EXE) $(TEST_INPUT)
		./sim_$(TEST_LANG)$(EXE) $(TEST_FLAGS) $(TEST_INPUT)

stream.res:	sim_$(TEST_LANG)$(EXE)
		./sim_$(TEST_LANG)$(EXE) -- $(TEST_FLAGS) $(TEST_INPUT) >$@
		wc $@ $(TEST_INPUT)
RES_GRB +=	stream.res

PERC_TEST_EXE	=	sim_text$(EXE)
PERC_TEST_FILES =	Test_percentages/foo_100 Test_percentages/foo_150
PERC_TEST_EXE	=	sim_c$(EXE)
PERC_TEST_FILES =	pasclang.l clang.l javalang.l
percentages.res:$(PERC_TEST_EXE) $(PERC_TEST_FILES)
		@echo ''
		./$(PERC_TEST_EXE) -T -p $(PERC_TEST_FILES)
		@echo ''
		./$(PERC_TEST_EXE) -T -pa $(PERC_TEST_FILES)
		@echo ''
		./$(PERC_TEST_EXE) -T -pae $(PERC_TEST_FILES)

version.res:	sim_$(TEST_LANG)$(EXE)
		./sim_$(TEST_LANG)$(EXE) -v


# More simple tests, using the C version only:
simsim:		sim_c$(EXE) $(SIM_SRC) $(PROP_SRC)
		./sim_c$(EXE) -fr 20 $(SIM_SRC) $(PROP_SRC)

# Lint
lint:		$(SIM_SRC) $(PROP_SRC) $(ABS_SRC) \
		$(SIM_HDR) $(PROP_HDR) $(ABS_HDR)
		$(LINT) $(LINTFLAGS) $(SIM_SRC) $(PROP_SRC) $(ABS_SRC)


#	O T H E R   E N T R I E S

# Documentation

view_man:	sim.pdf
		$(VIEW_PDF) sim.pdf

%.pdf:		%.tex
		$(LATEX) $< || log2errmsg <$*.log
		$(LATEX) $<
		$(LATEX) $<

SPC =		Similarity_Percentage_Computation
view_SPC:	$(SPC).pdf
		$(VIEW_PDF) $(SPC).pdf
DOCS +=		$(SPC).pdf

# LaTeX checker
chklat:
		chklat *.tex

# Installation
install_all:	install			# just a synonym
install:	$(DESTDIR)$(MAN1DIR)/sim.1 \
		$(DESTDIR)$(BINDIR)/sim_c$(EXE) \
		$(DESTDIR)$(BINDIR)/sim_text$(EXE) \
		$(DESTDIR)$(BINDIR)/sim_c++$(EXE) \
		$(DESTDIR)$(BINDIR)/sim_java$(EXE) \
		$(DESTDIR)$(BINDIR)/sim_pasc$(EXE) \
		$(DESTDIR)$(BINDIR)/sim_php$(EXE) \
		$(DESTDIR)$(BINDIR)/sim_m2$(EXE) \
		$(DESTDIR)$(BINDIR)/sim_lisp$(EXE) \
		$(DESTDIR)$(BINDIR)/sim_mira$(EXE) \
		$(DESTDIR)$(BINDIR)/sim_8086$(EXE)

$(DESTDIR)$(MAN1DIR)/sim.1:	sim.1
		$(COPY) sim.1 $@

$(DESTDIR)$(BINDIR)/sim_c$(EXE):	sim_c$(EXE)
		$(COPY) sim_c$(EXE) $@

$(DESTDIR)$(BINDIR)/sim_text$(EXE):	sim_text$(EXE)
		$(COPY) sim_text$(EXE) $@

$(DESTDIR)$(BINDIR)/sim_c++$(EXE):	sim_c++$(EXE)
		$(COPY) sim_c++$(EXE) $@

$(DESTDIR)$(BINDIR)/sim_java$(EXE):	sim_java$(EXE)
		$(COPY) sim_java$(EXE) $@

$(DESTDIR)$(BINDIR)/sim_pasc$(EXE):	sim_pasc$(EXE)
		$(COPY) sim_pasc$(EXE) $@

$(DESTDIR)$(BINDIR)/sim_php$(EXE):	sim_php$(EXE)
		$(COPY) sim_php$(EXE) $@

$(DESTDIR)$(BINDIR)/sim_m2$(EXE):	sim_m2$(EXE)
		$(COPY) sim_m2$(EXE) $@

$(DESTDIR)$(BINDIR)/sim_lisp$(EXE):	sim_lisp$(EXE)
		$(COPY) sim_lisp$(EXE) $@

$(DESTDIR)$(BINDIR)/sim_mira$(EXE):	sim_mira$(EXE)
		$(COPY) sim_mira$(EXE) $@

$(DESTDIR)$(BINDIR)/sim_8086$(EXE):	sim_8086$(EXE)
		$(COPY) sim_8086$(EXE) $@

# Clean-up

.PHONY:		distclean clean fresh
clean:
		-rm -f *.o
		-rm -f $(GEN_GRB)
		-rm -f $(RES_GRB)
		-rm -f *.aux *.log *.out
		-rm -f a.out a.exe sim.txt core mon.out
		-rm -f $(BINARIES)

fresh:		clean
		-rm -f *.exe

distclean:	fresh

#	D E P E N D E N C I E S

# DO NOT DELETE THIS LINE -- make depend depends on it.
ForEachFile.o: ForEachFile.c ForEachFile.h fname.h
Malloc.o: Malloc.c any_int.h Malloc.h
add_run.o: add_run.c global.h text.h runs.h percentages.h options.h \
 add_run.h
any_int.o: any_int.c any_int.h
compare.o: compare.c global.h text.h token.h tokenarray.h hash.h \
 properties.h options.h add_run.h compare.h debug.par
count_sim_dup.o: count_sim_dup.c
debug.o: debug.c debug.h
fname.o: fname.c fname.h
global.o: global.c global.h
hash.o: hash.c system.par debug.par global.h options.h text.h Malloc.h \
 any_int.h token.h properties.h tokenarray.h hash.h
idf.o: idf.c system.par token.h idf.h
lang.o: lang.c token.h properties.h idf.h lex.h lang.h
lex.o: lex.c lex.h
newargs.o: newargs.c global.h ForEachFile.h fname.h Malloc.h newargs.h
options.o: options.c options.h settings.par global.h
pass1.o: pass1.c debug.par global.h text.h token.h tokenarray.h lang.h \
 options.h pass1.h
pass2.o: pass2.c debug.par global.h token.h text.h lang.h pass2.h \
 sortlist.bdy
pass3.o: pass3.c system.par debug.par global.h options.h fname.h utf8.h \
 text.h token.h runs.h percentages.h pass3.h
percentages.o: percentages.c debug.par global.h text.h options.h Malloc.h \
 percentages.h sortlist.bdy
properties.o: properties.c global.h options.h token.h properties.h
runs.o: runs.c global.h text.h runs.h Malloc.h debug.par sortlist.bdy
sim.o: sim.c global.h options.h newargs.h token.h tokenarray.h text.h \
 compare.h pass1.h pass2.h pass3.h percentages.h stream.h lang.h Malloc.h \
 any_int.h
sim_gen.o: sim_gen.c global.h options.h token.h properties.h idf.h lex.h \
 lang.h
stream.o: stream.c system.par global.h token.h lang.h fname.h stream.h
text.o: text.c stream.h Malloc.h text.h
token.o: token.c token.h any_int.h
tokenarray.o: tokenarray.c global.h Malloc.h token.h tokenarray.h
utf8.o: utf8.c utf8.h
