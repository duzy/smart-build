# -*- mode: Makefile:gnu -*-
#	Copyright(c) 2009-2010, by Zhan Xin-ming <code@duzy.info>
#	

##
##  sm.tool.mingw32-gcc
##
##  This file exists mainly for cross building under Linux for MinGW32.
##

## make sure that gcc.mk is included only once
$(call sm-check-origin, sm.tool.mingw32-gcc, undefined)

TOOLSET_PREFIX := i586-mingw32msvc-

sm.tool.mingw32-gcc := true

## basic command names
sm.tool.mingw32-gcc.cmd.c := $(TOOLSET_PREFIX)gcc
sm.tool.mingw32-gcc.cmd.c++ := $(TOOLSET_PREFIX)g++
sm.tool.mingw32-gcc.cmd.asm := $(TOOLSET_PREFIX)gcc
sm.tool.mingw32-gcc.cmd.ld := $(TOOLSET_PREFIX)gcc
sm.tool.mingw32-gcc.cmd.ar := $(TOOLSET_PREFIX)ar crs

## languages supported by this toolset, the order is important,
## the order defines the priority of linker
sm.tool.mingw32-gcc.langs := c++ c asm
sm.tool.mingw32-gcc.suffix.c := .c
sm.tool.mingw32-gcc.suffix.c++ := .cpp .c++ .cc .CC .C
sm.tool.mingw32-gcc.suffix.asm := .s .S

## Compilation output files(objects) suffixes.
sm.tool.mingw32-gcc.suffix.intermediate.c := .o
sm.tool.mingw32-gcc.suffix.intermediate.c++ := .o
sm.tool.mingw32-gcc.suffix.intermediate.asm := .o

sm.tool.mingw32-gcc.suffix.target.static.win32 = $(error cross MinGW32 compiling on Win32 not allowed)
sm.tool.mingw32-gcc.suffix.target.shared.win32 = $(error cross MinGW32 compiling on Win32 not allowed)
sm.tool.mingw32-gcc.suffix.target.exe.win32 = $(error cross MinGW32 compiling on Win32 not allowed)
sm.tool.mingw32-gcc.suffix.target.t.win32 = $(error cross MinGW32 compiling on Win32 not allowed)
sm.tool.mingw32-gcc.suffix.target.depends.win32 = $(error cross MinGW32 compiling on Win32 not allowed)
sm.tool.mingw32-gcc.suffix.target.static.linux := .a
sm.tool.mingw32-gcc.suffix.target.shared.linux := .so
sm.tool.mingw32-gcc.suffix.target.exe.linux := .exe
sm.tool.mingw32-gcc.suffix.target.t.linux := .test.exe
sm.tool.mingw32-gcc.suffix.target.depends.linux :=

######################################################################
# Compiles

define sm.tool.mingw32-gcc.compile.c.private
$(info $(sm.args.target) $(sm.args.sources))
$(sm.tool.mingw32-gcc.cmd.c) $(sm.args.flags.0) -c -o $(sm.args.target) $(sm.args.sources)
endef #sm.tool.mingw32-gcc.compile.c.private

define sm.tool.mingw32-gcc.compile.c++.private
$(sm.tool.mingw32-gcc.cmd.c++) $(sm.args.flags.0) -c -o $(sm.args.target) $(sm.args.sources)
endef #sm.tool.mingw32-gcc.compile.c++.private

define sm.tool.mingw32-gcc.compile.asm.private
$(sm.tool.mingw32-gcc.cmd.asm) $(sm.args.flags.0) -c -o $(sm.args.target) $(sm.args.sources)
endef #sm.tool.mingw32-gcc.compile.asm.private

sm.tool.mingw32-gcc.compile     = $(call sm.tool.mingw32-gcc.compile.$(sm.args.lang).private)
sm.tool.mingw32-gcc.compile.c   = $(eval sm.args.lang:=c)$(sm.tool.mingw32-gcc.compile)
sm.tool.mingw32-gcc.compile.c++ = $(eval sm.args.lang:=c++)$(sm.tool.mingw32-gcc.compile)
sm.tool.mingw32-gcc.compile.asm = $(eval sm.args.lang:=asm)$(sm.tool.mingw32-gcc.compile)


##################################################
# Denpendencies

define sm.tool.mingw32-gcc.dependency.c.private
$(sm.tool.mingw32-gcc.cmd.c) -MM -MT $(sm.args.target) -MF $(sm.args.output) $(sm.args.flags.0) $(sm.args.sources)
endef #sm.tool.mingw32-gcc.dependency.c.private

define sm.tool.mingw32-gcc.dependency.c++.private
$(sm.tool.mingw32-gcc.cmd.c++) -MM -MT $(sm.args.target) -MF $(sm.args.output) $(sm.args.flags.0) $(sm.args.sources)
endef #sm.tool.mingw32-gcc.dependency.c++.private

sm.tool.mingw32-gcc.dependency     = $(call sm.tool.mingw32-gcc.dependency.$(sm.args.lang).private)
sm.tool.mingw32-gcc.dependency.c   = $(eval sm.args.lang:=c)$(call sm.tool.mingw32-gcc.dependency)
sm.tool.mingw32-gcc.dependency.c++ = $(eval sm.args.lang:=c++)$(call sm.tool.mingw32-gcc.dependency)
sm.tool.mingw32-gcc.dependency.asm = $(eval sm.args.lang:=asm)$(call sm.tool.mingw32-gcc.dependency)


##################################################
# Links

define sm.tool.mingw32-gcc.link.c
$(sm.tool.mingw32-gcc.cmd.c) $(sm.args.flags.0) -o $(sm.args.target) $(sm.args.sources) $(sm.args.flags.1)
endef #sm.tool.mingw32-gcc.link.c

define sm.tool.mingw32-gcc.link.c++
$(sm.tool.mingw32-gcc.cmd.c++) $(sm.args.flags.0) -o $(sm.args.target) $(sm.args.sources) $(sm.args.flags.1)
endef #sm.tool.mingw32-gcc.link.c++

define sm.tool.mingw32-gcc.link.asm
$(sm.tool.mingw32-gcc.cmd.as) $(sm.args.flags.0) -o $(sm.args.target) $(sm.args.sources) $(sm.args.flags.1)
endef #sm.tool.mingw32-gcc.link.asm

define sm.tool.mingw32-gcc.link
$(sm.tool.mingw32-gcc.cmd.ld) $(sm.args.flags.0) -o $(sm.args.target) $(sm.args.sources) $(sm.args.flags.1)
endef #sm.tool.mingw32-gcc.link


##################################################
# Archive

define sm.tool.mingw32-gcc.archive
$(sm.tool.mingw32-gcc.cmd.ar) $(sm.args.target) $(sm.args.sources)
endef #sm.tool.mingw32-gcc.archive

sm.tool.mingw32-gcc.archive.c   = $(sm.tool.mingw32-gcc.archive)
sm.tool.mingw32-gcc.archive.c++ = $(sm.tool.mingw32-gcc.archive)
sm.tool.mingw32-gcc.archive.asm = $(sm.tool.mingw32-gcc.archive)


######################################################################
# Options

ifeq ($(strip $(sm.config.variant)),debug)
  sm.tool.mingw32-gcc.compile.options := -g -ggdb
  sm.tool.mingw32-gcc.link.options :=
else
ifeq ($(strip $(sm.config.variant)),release)
  sm.tool.mingw32-gcc.compile.options := -O3
  sm.tool.mingw32-gcc.link.options :=
endif
endif

ifeq ($(sm.os.name),linux)
else
ifeq ($(sm.os.name),win32)
  sm.tool.mingw32-gcc.compile.options += -mwindows
  sm.tool.mingw32-gcc.link.options += -mwindows \
    -Wl,--enable-runtime-pseudo-reloc \
    -Wl,--enable-auto-import \
    $(null)
endif#win32
endif#linux

sm.tool.mingw32-gcc.link.options += -Wl,--no-undefined
