# -*- mode: Makefile:gnu -*-
#	Copyright(c) 2009-2010, by Zhan Xin-ming, duzy@duzy.info
#	

##
##  sm.tool.gcc
##

$(call sm-check-origin, sm.tool.gcc, undefined)

sm.tool.gcc := true

sm.tool.gcc.cmd.cc := gcc
sm.tool.gcc.cmd.c++ := g++
sm.tool.gcc.cmd.as := gas
sm.tool.gcc.cmd.ld := ld

## languages supported by this toolset
sm.tool.gcc.langs := c c++ asm
sm.tool.gcc.c.suffix :=
sm.tool.gcc.c++.suffix :=
sm.tool.gcc.asm.suffix :=

##################################################
# Compiles

##
##  Produce compile commands for 
##
define sm.tool.gcc.compile.c.unchecked
$(sm.tool.gcc.cmd.cc) $($(strip $3)) -c -o $(strip $1) $(strip $2)
endef #sm.tool.gcc.compile.c.unchecked

##
##
##
define sm.tool.gcc.compile.c++.unchecked
$(sm.tool.gcc.cmd.c++) $($(strip $3)) -c -o $(strip $1) $(strip $2)
endef #sm.tool.gcc.compile.c++.unchecked

##
##
##
define sm.tool.gcc.compile.asm.unchecked
$(sm.tool.gcc.cmd.asm) $($(strip $3)) -c -o $(strip $1) $(strip $2)
endef #sm.tool.gcc.compile.asm.unchecked

##
##
##
define sm.tool.gcc.compile
$(if $1,,$(error smart: arg \#1 must be the source language))\
$(if $2,,$(error smart: arg \#2 must be the output target))\
$(if $3,,$(error smart: arg \#3 must be the source file))\
$(if $4,,$(error smart: arg \#4 must be a callback for compile flags))\
$(call sm.tool.gcc.compile.$(strip $1).unchecked,$2,$3,$(strip $4))
endef #sm.tool.gcc.compile

sm.tool.gcc.compile.c = $(call sm.tool.gcc.compile,c,$1,$2,$3)
sm.tool.gcc.compile.c++ = $(call sm.tool.gcc.compile,c++,$1,$2,$3)
sm.tool.gcc.compile.asm = $(call sm.tool.gcc.compile,asm,$1,$2,$3)


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

