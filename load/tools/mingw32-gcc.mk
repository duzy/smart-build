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

NULL :=

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

##
##  Produce compile commands for c language
##
define sm.tool.mingw32-gcc.compile.c.private
$(sm.tool.mingw32-gcc.cmd.c) $(strip $3) -c -o $(strip $1) $(strip $2)
endef #sm.tool.mingw32-gcc.compile.c.private

##
##
##
define sm.tool.mingw32-gcc.compile.c++.private
$(sm.tool.mingw32-gcc.cmd.c++) $(strip $3) -c -o $(strip $1) $(strip $2)
endef #sm.tool.mingw32-gcc.compile.c++.private

##
##
##
define sm.tool.mingw32-gcc.compile.asm.private
$(sm.tool.mingw32-gcc.cmd.asm) $(strip $3) -c -o $(strip $1) $(strip $2)
endef #sm.tool.mingw32-gcc.compile.asm.private

##
##
##
define sm.tool.mingw32-gcc.compile
$(if $1,,$(error smart: arg 1 must be the source language))\
$(if $2,,$(error smart: arg 2 must be the output target))\
$(if $3,,$(error smart: arg 3 must be the source file))\
$(if $4,,$(error smart: arg 4 must be compile flags))\
$(call sm.tool.mingw32-gcc.compile.$(strip $1).private,$2,$3,$(strip $4))
endef #sm.tool.mingw32-gcc.compile

sm.tool.mingw32-gcc.compile.c = $(call sm.tool.mingw32-gcc.compile,c,$1,$2,$3)
sm.tool.mingw32-gcc.compile.c++ = $(call sm.tool.mingw32-gcc.compile,c++,$1,$2,$3)
sm.tool.mingw32-gcc.compile.asm = $(call sm.tool.mingw32-gcc.compile,asm,$1,$2,$3)


##################################################
# Denpendencies

define sm.tool.mingw32-gcc.dependency.c.private
$(sm.tool.mingw32-gcc.cmd.c) -MM -MT $(strip $2) -MF $(strip $1) $(strip $4) $(strip $3)
endef #sm.tool.mingw32-gcc.dependency.c.private

define sm.tool.mingw32-gcc.dependency.c++.private
$(sm.tool.mingw32-gcc.cmd.c++) -MM -MT $(strip $2) -MF $(strip $1) $(strip $4) $(strip $3)
endef #sm.tool.mingw32-gcc.dependency.c++.private

## eg. $(sm.tool.mingw32-gcc.dependency, foo.d, foo.o, src/foo.cpp)
define sm.tool.mingw32-gcc.dependency
$(if $1,,$(error smart: arg 1 must be the source language))\
$(if $2,,$(error smart: arg 2 must be the output target))\
$(if $3,,$(error smart: arg 3 must be the source file))\
$(if $4,,$(error smart: arg 4 must be compile flags))\
$(call sm.tool.mingw32-gcc.dependency.$(strip $1).private,$2,$3,$(strip $4),$(strip $5))
endef #sm.tool.mingw32-gcc.dependency

sm.tool.mingw32-gcc.dependency.c = $(call sm.tool.mingw32-gcc.dependency,c,$1,$2,$3,$4)
sm.tool.mingw32-gcc.dependency.c++ = $(call sm.tool.mingw32-gcc.dependency,c++,$1,$2,$3,$4)
sm.tool.mingw32-gcc.dependency.asm = $(call sm.tool.mingw32-gcc.dependency,asm,$1,$2,$3,$4)


##################################################
# Links

##
##
##
define sm.tool.mingw32-gcc.link.c
$(sm.tool.mingw32-gcc.cmd.c) $(strip $3) -o $(strip $1) $(strip $2) $(strip $4)
endef #sm.tool.mingw32-gcc.link.c

##
##
##
define sm.tool.mingw32-gcc.link.c++
$(sm.tool.mingw32-gcc.cmd.c++) $(strip $3) -o $(strip $1) $(strip $2) $(strip $4)
endef #sm.tool.mingw32-gcc.link.c++

##
##
##
define sm.tool.mingw32-gcc.link.asm
$(sm.tool.mingw32-gcc.cmd.as) $(strip $3) -o $(strip $1) $(strip $2) $(strip $4)
endef #sm.tool.mingw32-gcc.link.asm

##
##
## eg. $(call sm.tool.mingw32-gcc.link, foo, foo.c, options, libs)
define sm.tool.mingw32-gcc.link
$(sm.tool.mingw32-gcc.cmd.ld) $(strip $3) -o $(strip $1) $(strip $2) $(strip $4)
endef


##################################################
# Archive

define sm.tool.mingw32-gcc.archive
$(sm.tool.mingw32-gcc.cmd.ar) $(strip $1) $(strip $2)
endef

sm.tool.mingw32-gcc.archive.c   = $(call sm.tool.mingw32-gcc.archive,$1,$2,$3,$4)
sm.tool.mingw32-gcc.archive.c++ = $(call sm.tool.mingw32-gcc.archive,$1,$2,$3,$4)
sm.tool.mingw32-gcc.archive.asm = $(call sm.tool.mingw32-gcc.archive,$1,$2,$3,$4)


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
    $(NULL)
endif#win32
endif#linux

sm.tool.mingw32-gcc.link.options += -Wl,--no-undefined
