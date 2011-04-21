# -*- mode: Makefile:gnu -*-
#	Copyright(c) 2009-2010, by Zhan Xin-ming <code@duzy.info>
#	

##
##  sm.tool.gcc
##

## make sure that gcc.mk is included only once
$(call sm-check-origin, sm.tool.gcc, undefined)

NULL :=

sm.tool.gcc := true

## basic command names
sm.tool.gcc.cmd.c := gcc
sm.tool.gcc.cmd.c++ := g++
sm.tool.gcc.cmd.asm := gcc
sm.tool.gcc.cmd.ld := gcc
sm.tool.gcc.cmd.ar := ar crs

## languages supported by this toolset, the order is important,
## the order defines the priority of linker
sm.tool.gcc.langs := c++ c asm
sm.tool.gcc.c.suffix := .c
sm.tool.gcc.c++.suffix := .cpp .c++ .cc .CC .C
sm.tool.gcc.asm.suffix := .s .S

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
$(sm.tool.gcc.cmd.c) $(strip $3) -c -o $(strip $1) $(strip $2)
endef #sm.tool.gcc.compile.c.private

##
##
##
define sm.tool.gcc.compile.c++.private
$(sm.tool.gcc.cmd.c++) $(strip $3) -c -o $(strip $1) $(strip $2)
endef #sm.tool.gcc.compile.c++.private

##
##
##
define sm.tool.gcc.compile.asm.private
$(sm.tool.gcc.cmd.asm) $(strip $3) -c -o $(strip $1) $(strip $2)
endef #sm.tool.gcc.compile.asm.private

##
##
##
define sm.tool.gcc.compile
$(if $1,,$(error smart:gcc: arg 1 must be the source language: $1))\
$(if $2,,$(error smart:gcc: arg 2 must be the output target: $2))\
$(if $3,,$(error smart:gcc: arg 3 must be the source file: $3))\
$(call sm.tool.gcc.compile.$(strip $1).private,$2,$3,$(strip $4))
endef #sm.tool.gcc.compile

sm.tool.gcc.compile.c = $(call sm.tool.gcc.compile,c,$1,$2,$3)
sm.tool.gcc.compile.c++ = $(call sm.tool.gcc.compile,c++,$1,$2,$3)
sm.tool.gcc.compile.asm = $(call sm.tool.gcc.compile,asm,$1,$2,$3)
# sm.tool.gcc.compile.c = $(call sm.tool.gcc.compile,c)
# sm.tool.gcc.compile.c++ = $(call sm.tool.gcc.compile,c++)
# sm.tool.gcc.compile.asm = $(call sm.tool.gcc.compile,asm)


##################################################
# Denpendencies

define sm.tool.gcc.dependency.c.private
$(sm.tool.gcc.cmd.c) -MM -MT $(strip $2) -MF $(strip $1) $(strip $4) $(strip $3)
endef #sm.tool.gcc.dependency.c.private

define sm.tool.gcc.dependency.c++.private
$(sm.tool.gcc.cmd.c++) -MM -MT $(strip $2) -MF $(strip $1) $(strip $4) $(strip $3)
endef #sm.tool.gcc.dependency.c++.private

## eg. $(sm.tool.gcc.dependency, c++, foo.d, src/foo.cpp, -DXXX)
define sm.tool.gcc.dependency
$(if $1,,$(error smart:gcc: arg 1 must be the source language: $1))\
$(if $2,,$(error smart:gcc: arg 2 must be the output target: $2))\
$(if $3,,$(error smart:gcc: arg 3 must be the source file: $3))\
$(call sm.tool.gcc.dependency.$(strip $1).private,$2,$3,$(strip $4),$(strip $5))
endef #sm.tool.gcc.dependency

sm.tool.gcc.dependency.c = $(call sm.tool.gcc.dependency,c,$1,$2,$3,$4)
sm.tool.gcc.dependency.c++ = $(call sm.tool.gcc.dependency,c++,$1,$2,$3,$4)
sm.tool.gcc.dependency.asm = $(call sm.tool.gcc.dependency,asm,$1,$2,$3,$4)
# sm.tool.gcc.dependency.c = $(call sm.tool.gcc.dependency,c)
# sm.tool.gcc.dependency.c++ = $(call sm.tool.gcc.dependency,c++)
# sm.tool.gcc.dependency.asm = $(call sm.tool.gcc.dependency,asm)


##################################################
# Links

##
##
##
define sm.tool.gcc.link.c
$(sm.tool.gcc.cmd.c) $(strip $3) -o $(strip $1) $(strip $2) $(strip $4)
endef #sm.tool.gcc.link.c

##
##
##
define sm.tool.gcc.link.c++
$(sm.tool.gcc.cmd.c++) $(strip $3) -o $(strip $1) $(strip $2) $(strip $4)
endef #sm.tool.gcc.link.c++

##
##
##
define sm.tool.gcc.link.asm
$(sm.tool.gcc.cmd.as) $(strip $3) -o $(strip $1) $(strip $2) $(strip $4)
endef #sm.tool.gcc.link.asm

##
##
## eg. $(call sm.tool.gcc.link, foo, foo.c, options, libs)
define sm.tool.gcc.link
$(sm.tool.gcc.cmd.ld) $(strip $3) -o $(strip $1) $(strip $2) $(strip $4)
endef


##################################################
# Archive

define sm.tool.gcc.archive
$(sm.tool.gcc.cmd.ar) $(strip $1) $(strip $2)
endef

sm.tool.gcc.archive.c   = $(call sm.tool.gcc.archive,$1,$2,$3,$4)
sm.tool.gcc.archive.c++ = $(call sm.tool.gcc.archive,$1,$2,$3,$4)
sm.tool.gcc.archive.asm = $(call sm.tool.gcc.archive,$1,$2,$3,$4)
# sm.tool.gcc.archive.c   = $(call sm.tool.gcc.archive)
# sm.tool.gcc.archive.c++ = $(call sm.tool.gcc.archive)
# sm.tool.gcc.archive.asm = $(call sm.tool.gcc.archive)


######################################################################
# Options

ifeq ($(strip $(sm.config.variant)),debug)
  sm.tool.gcc.compile.options := -g -ggdb
  sm.tool.gcc.link.options :=
else
ifeq ($(strip $(sm.config.variant)),release)
  sm.tool.gcc.compile.options := -O3
  sm.tool.gcc.link.options :=
endif
endif

ifeq ($(sm.os.name),linux)
else
ifeq ($(sm.os.name),win32)
  sm.tool.gcc.compile.options += -mwindows
  sm.tool.gcc.link.options += -mwindows \
    -Wl,--enable-runtime-pseudo-reloc \
    -Wl,--enable-auto-import \
    $(NULL)
endif#win32
endif#linux

sm.tool.gcc.link.options += -Wl,--no-undefined
