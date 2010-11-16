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
sm.tool.gcc.cmd.cc := gcc
sm.tool.gcc.cmd.c++ := g++
sm.tool.gcc.cmd.asm := gas
sm.tool.gcc.cmd.ld := ld
sm.tool.gcc.cmd.ar := ar crs

## languages supported by this toolset, the order is important,
## the order defines the priority of linker
sm.tool.gcc.langs := c++ c asm
sm.tool.gcc.c.suffix :=
sm.tool.gcc.c++.suffix :=
sm.tool.gcc.asm.suffix :=

######################################################################
# Compiles

##
##  Produce compile commands for c language
##
define sm.tool.gcc.compile.c.private
$(sm.tool.gcc.cmd.cc) $($(strip $3)) -c -o $(strip $1) $(strip $2)
endef #sm.tool.gcc.compile.c.private

##
##
##
define sm.tool.gcc.compile.c++.private
$(sm.tool.gcc.cmd.c++) $($(strip $3)) -c -o $(strip $1) $(strip $2)
endef #sm.tool.gcc.compile.c++.private

##
##
##
define sm.tool.gcc.compile.asm.private
$(sm.tool.gcc.cmd.asm) $($(strip $3)) -c -o $(strip $1) $(strip $2)
endef #sm.tool.gcc.compile.asm.private

##
##
##
define sm.tool.gcc.compile
$(if $1,,$(error smart: arg \#1 must be the source language))\
$(if $2,,$(error smart: arg \#2 must be the output target))\
$(if $3,,$(error smart: arg \#3 must be the source file))\
$(if $4,,$(error smart: arg \#4 must be a callback for compile flags))\
$(call sm.tool.gcc.compile.$(strip $1).private,$2,$3,$(strip $4))
endef #sm.tool.gcc.compile

sm.tool.gcc.compile.c = $(call sm.tool.gcc.compile,c,$1,$2,$3)
sm.tool.gcc.compile.c++ = $(call sm.tool.gcc.compile,c++,$1,$2,$3)
sm.tool.gcc.compile.asm = $(call sm.tool.gcc.compile,asm,$1,$2,$3)


##################################################
# Denpendencies

define sm.tool.gcc.dependency.c.private
$(sm.tool.gcc.cmd.cc) -MM -MT $(strip $2) -MF $(strip $1) $($(strip $4)) $(strip $3)
endef #sm.tool.gcc.dependency.c.private

define sm.tool.gcc.dependency.c++.private
$(sm.tool.gcc.cmd.c++) -MM -MT $(strip $2) -MF $(strip $1) $($(strip $4)) $(strip $3)
endef #sm.tool.gcc.dependency.c++.private

## eg. $(sm.tool.gcc.dependency, foo.d, foo.o, src/foo.cpp)
define sm.tool.gcc.dependency
$(if $1,,$(error smart: arg \#1 must be the source language))\
$(if $2,,$(error smart: arg \#2 must be the output target))\
$(if $3,,$(error smart: arg \#3 must be the source file))\
$(if $4,,$(error smart: arg \#4 must be a callback for compile flags))\
$(call sm.tool.gcc.dependency.$(strip $1).private,$2,$3,$(strip $4),$(strip $5))
endef #sm.tool.gcc.dependency

sm.tool.gcc.dependency.c = $(call sm.tool.gcc.dependency,c,$1,$2,$3,$4)
sm.tool.gcc.dependency.c++ = $(call sm.tool.gcc.dependency,c++,$1,$2,$3,$4)
sm.tool.gcc.dependency.asm = $(call sm.tool.gcc.dependency,asm,$1,$2,$3,$4)


##################################################
# Links

##
##
##
define sm.tool.gcc.link.c
$(sm.tool.gcc.cmd.cc) $($(strip $3)) -o $(strip $1) $(strip $2) $($(strip $4))
endef #sm.tool.gcc.link.c

##
##
##
define sm.tool.gcc.link.c++
$(sm.tool.gcc.cmd.c++) $($(strip $3)) -o $(strip $1) $(strip $2) $($(strip $4))
endef #sm.tool.gcc.link.c++

##
##
##
define sm.tool.gcc.link.asm
$(sm.tool.gcc.cmd.as) $($(strip $3)) -o $(strip $1) $(strip $2) $($(strip $4))
endef #sm.tool.gcc.link.asm

##
##
## eg. $(call sm.tool.gcc.link, foo, foo.c, callback-get-options, callback-get-libs)
define sm.tool.gcc.link
$(sm.tool.gcc.cmd.ld) $($(strip $3)) -o $(strip $1) $(strip $2) $($(strip $4))
endef


##################################################
# Archive

define sm.tool.gcc.archive
$(sm.tool.gcc.cmd.ar) $(strip $1) $(strip $2)
endef

sm.tool.gcc.archive.c   = $(call sm.tool.gcc.archive,$1,$2,$3,$4)
sm.tool.gcc.archive.c++ = $(call sm.tool.gcc.archive,$1,$2,$3,$4)
sm.tool.gcc.archive.asm = $(call sm.tool.gcc.archive,$1,$2,$3,$4)


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

sm.tool.gcc.link.options += -Wl,--no-undefined
