# -*- mode: Makefile:gnu -*-
#	Copyright(c) 2009-2010, by Zhan Xin-ming <code@duzy.info>
#	

##
##  sm.tool.gcc
##

## make sure that gcc.mk is included only once
$(call sm-check-origin, sm.tool.gcc, undefined)

sm.tool.gcc := true

## basic command names
sm.tool.gcc.cmd.c := gcc
sm.tool.gcc.cmd.c++ := g++
sm.tool.gcc.cmd.asm := gcc
sm.tool.gcc.cmd.ld := gcc
sm.tool.gcc.cmd.ar := ar crs

## Languages supported by this toolset, the order is significant,
## the order defines the priority of linker
sm.tool.gcc.langs := c++ c asm
sm.tool.gcc.c.suffix := .c
sm.tool.gcc.c++.suffix := .cpp .c++ .cc .CC .C
sm.tool.gcc.asm.suffix := .s .S

## Compilation output files(objects) suffixes.
sm.tool.gcc.intermediate.suffix.c := .o
sm.tool.gcc.intermediate.suffix.c++ := .o
sm.tool.gcc.intermediate.suffix.asm := .o

## Target link output file suffix.
sm.tool.gcc.target.suffix.win32.static := .a
sm.tool.gcc.target.suffix.win32.shared := .so
sm.tool.gcc.target.suffix.win32.exe := .exe
sm.tool.gcc.target.suffix.win32.t := .test.exe
sm.tool.gcc.target.suffix.win32.depends :=
sm.tool.gcc.target.suffix.linux.static := .a
sm.tool.gcc.target.suffix.linux.shared := .so
sm.tool.gcc.target.suffix.linux.exe :=
sm.tool.gcc.target.suffix.linux.t := .test
sm.tool.gcc.target.suffix.linux.depends :=

######################################################################
# Compiles

##
##  Produce compile commands for c language
##
define sm.tool.gcc.compile.c.private
$(sm.tool.gcc.cmd.c) $(sm.args.flags.0) -c -o $(sm.args.target) $(sm.args.sources)
endef #sm.tool.gcc.compile.c.private

##
##
##
define sm.tool.gcc.compile.c++.private
$(sm.tool.gcc.cmd.c++) $(sm.args.flags.0) -c -o $(sm.args.target) $(sm.args.sources)
endef #sm.tool.gcc.compile.c++.private

##
##
##
define sm.tool.gcc.compile.asm.private
$(sm.tool.gcc.cmd.asm) $(sm.args.flags.0) -c -o $(sm.args.target) $(sm.args.sources)
endef #sm.tool.gcc.compile.asm.private

##
##
##
sm.tool.gcc.compile     = $(call sm.tool.gcc.compile.$(sm.args.lang).private)
sm.tool.gcc.compile.c   = $(eval sm.args.lang:=c)$(sm.tool.gcc.compile)
sm.tool.gcc.compile.c++ = $(eval sm.args.lang:=c++)$(sm.tool.gcc.compile)
sm.tool.gcc.compile.asm = $(eval sm.args.lang:=asm)$(sm.tool.gcc.compile)

##################################################
# Denpendencies

define sm.tool.gcc.dependency.c.private
$(sm.tool.gcc.cmd.c) -MM -MT $(sm.args.target) -MF $(sm.args.output) $(sm.args.flags.0) $(sm.args.sources)
endef #sm.tool.gcc.dependency.c.private

define sm.tool.gcc.dependency.c++.private
$(sm.tool.gcc.cmd.c++) -MM -MT $(sm.args.target) -MF $(sm.args.output) $(sm.args.flags.0) $(sm.args.sources)
endef #sm.tool.gcc.dependency.c++.private

sm.tool.gcc.dependency     = $(call sm.tool.gcc.dependency.$(sm.args.lang).private)
sm.tool.gcc.dependency.c   = $(eval sm.args.lang:=c)$(sm.tool.gcc.dependency)
sm.tool.gcc.dependency.c++ = $(eval sm.args.lang:=c++)$(sm.tool.gcc.dependency)
sm.tool.gcc.dependency.asm = $(eval sm.args.lang:=casm)$(sm.tool.gcc.dependency)


##################################################
# Links

##
##
##
define sm.tool.gcc.link.c
$(sm.tool.gcc.cmd.c) $(sm.args.flags.0) -o $(sm.args.target) $(sm.args.sources) $(sm.args.flags.1)
endef #sm.tool.gcc.link.c

##
##
##
define sm.tool.gcc.link.c++
$(sm.tool.gcc.cmd.c++) $(sm.args.flags.0) -o $(sm.args.target) $(sm.args.sources) $(sm.args.flags.1)
endef #sm.tool.gcc.link.c++

##
##
##
define sm.tool.gcc.link.asm
$(sm.tool.gcc.cmd.asm) $(sm.args.flags.0) -o $(sm.args.target) $(sm.args.sources) $(sm.args.flags.1)
endef #sm.tool.gcc.link.asm

##
##
## eg. $(call sm.tool.gcc.link, foo, foo.c, options, libs)
define sm.tool.gcc.link
$(sm.tool.gcc.cmd.ld) $(sm.args.flags.0) -o $(sm.args.target) $(sm.args.sources) $(sm.args.flags.1)
endef #sm.tool.gcc.link


##################################################
# Archive

define sm.tool.gcc.archive
$(sm.tool.gcc.cmd.ar) $(sm.args.target) $(sm.args.sources)
endef #sm.tool.gcc.archive

sm.tool.gcc.archive.c   = $(sm.tool.gcc.archive)
sm.tool.gcc.archive.c++ = $(sm.tool.gcc.archive)
sm.tool.gcc.archive.asm = $(sm.tool.gcc.archive)


######################################################################
# Options

sm.tool.gcc.compile.flags :=
sm.tool.gcc.link.flags :=

ifeq ($(strip $(sm.config.variant)),debug)
  sm.tool.gcc.compile.flags += -g -ggdb
  sm.tool.gcc.link.flags +=
else
ifeq ($(strip $(sm.config.variant)),release)
  sm.tool.gcc.compile.flags += -O3
  sm.tool.gcc.link.flags +=
endif
endif

ifeq ($(sm.os.name),linux)
else
ifeq ($(sm.os.name),win32)
  sm.tool.gcc.compile.flags += -mwindows
  sm.tool.gcc.link.flags += -mwindows \
    -Wl,--enable-runtime-pseudo-reloc \
    -Wl,--enable-auto-import \
    $(null)
endif#win32
endif#linux

sm.tool.gcc.link.flags += -Wl,--no-undefined
