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

null :=

TOOLSET_PRE := i586-mingw32msvc-

sm.tool.mingw32-gcc := true
sm.tool.mingw32-gcc.prefix := $(TOOLSET_PRE)

## basic command names
sm.tool.mingw32-gcc.cmd.c := $(TOOLSET_PRE)gcc
sm.tool.mingw32-gcc.cmd.c++ := $(TOOLSET_PRE)g++
sm.tool.mingw32-gcc.cmd.asm := $(TOOLSET_PRE)gcc
sm.tool.mingw32-gcc.cmd.ld := $(TOOLSET_PRE)gcc
sm.tool.mingw32-gcc.cmd.ar := $(TOOLSET_PRE)ar crs

## languages supported by this toolset, the order is important,
## the order defines the priority of linker
sm.tool.mingw32-gcc.langs := c++ c asm
sm.tool.mingw32-gcc.c.suffix := .c
sm.tool.mingw32-gcc.c++.suffix := .cpp .c++ .cc .CC .C
sm.tool.mingw32-gcc.asm.suffix := .s .S

sm.tool.mingw32-gcc.target.suffix.win32.static := .a
sm.tool.mingw32-gcc.target.suffix.win32.shared := .so
sm.tool.mingw32-gcc.target.suffix.win32.exe := .exe
sm.tool.mingw32-gcc.target.suffix.win32.t := .test.exe
sm.tool.mingw32-gcc.target.suffix.win32.depends :=
sm.tool.mingw32-gcc.target.suffix.linux.static := .a
sm.tool.mingw32-gcc.target.suffix.linux.shared := .so
sm.tool.mingw32-gcc.target.suffix.linux.exe := .exe
sm.tool.mingw32-gcc.target.suffix.linux.t := .test.exe
sm.tool.mingw32-gcc.target.suffix.linux.depends :=

######################################################################
# Compiles

define sm.tool.mingw32-gcc.compile.c.private
$(sm.tool.mingw32-gcc.cmd.c) $(sm.args.flags.0) -c -o $(sm.args.target) $(sm.args.sources)
endef #sm.tool.mingw32-gcc.compile.c.private

define sm.tool.mingw32-gcc.compile.c++.private
$(sm.tool.mingw32-gcc.cmd.c++) $(sm.args.flags.0) -c -o $(sm.args.target) $(sm.args.sources)
endef #sm.tool.mingw32-gcc.compile.c++.private

define sm.tool.mingw32-gcc.compile.asm.private
$(sm.tool.mingw32-gcc.cmd.asm) $(sm.args.flags.0) -c -o $(sm.args.target) $(sm.args.sources)
endef #sm.tool.mingw32-gcc.compile.asm.private

sm.tool.mingw32-gcc.compile     = $(sm.tool.mingw32-gcc.compile.private)
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

sm.tool.mingw32-gcc.dependency     = $(call sm.tool.mingw32-gcc.dependency.private)
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
