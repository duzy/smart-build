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
sm.tool.gcc.suffix.c := .c
sm.tool.gcc.suffix.c++ := .cpp .c++ .cc .CC .C
sm.tool.gcc.suffix.asm := .s .S

## Compilation output files(objects) suffixes.
sm.tool.gcc.suffix.intermediate.c := .o
sm.tool.gcc.suffix.intermediate.c++ := .o
sm.tool.gcc.suffix.intermediate.asm := .o

## Target link output file suffix.
sm.tool.gcc.suffix.target.static.win32 := .a
sm.tool.gcc.suffix.target.shared.win32 := .so
sm.tool.gcc.suffix.target.exe.win32 := .exe
sm.tool.gcc.suffix.target.t.win32 := .test.exe
sm.tool.gcc.suffix.target.depends.win32 :=
sm.tool.gcc.suffix.target.static.linux := .a
sm.tool.gcc.suffix.target.shared.linux := .so
sm.tool.gcc.suffix.target.exe.linux :=
sm.tool.gcc.suffix.target.t.linux := .test
sm.tool.gcc.suffix.target.depends.linux :=

######################################################################
# define sm.tool.gcc.compile.c
# define sm.tool.gcc.compile.c++
# define sm.tool.gcc.compile.asm
#
# define sm.tool.gcc.dependency.c
# define sm.tool.gcc.dependency.c++
# define sm.tool.gcc.dependency.asm
#
# define sm.tool.gcc.link.c
# define sm.tool.gcc.link.c++
# define sm.tool.gcc.link.asm
#
# sm.tool.gcc.archive.c
# sm.tool.gcc.archive.c++
# sm.tool.gcc.archive.asm
#
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
