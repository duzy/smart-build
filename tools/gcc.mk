# -*- mode: Makefile:gnu -*-
#	Copyright(c) 2009-2010, by Zhan Xin-ming, duzy@duzy.info
#	

##
##  sm.tool.gcc
##

$(info smart: gcc toolset included)
$(call sm-check-origin, sm.tool.gcc, undefined)

sm.tool.gcc := true

sm.tool.gcc.cmd.cc := gcc
sm.tool.gcc.cmd.c++ := g++
sm.tool.gcc.cmd.as := gas
sm.tool.gcc.cmd.ld := ld


##################################################
# Compiles

##
##  Produce compile commands for 
##
define sm.tool.gcc.compile.c.unchecked
$(call sm-util-mkdir,$(dir $1))\
$(sm.tool.gcc.cmd.cc) -c -o $(strip $1) $(strip $2)
endef #sm.tool.gcc.compile.c.unchecked

##
##
##
define sm.tool.gcc.compile.c++.unchecked
$(call sm-util-mkdir,$(dir $1))\
$(sm.tool.gcc.cmd.c++) -c -o $(strip $1) $(strip $2)
endef #sm.tool.gcc.compile.c++.unchecked

##
##
##
define sm.tool.gcc.compile.asm.unchecked
$(call sm-util-mkdir,$(dir $1))\
$(sm.tool.gcc.cmd.asm) -c -o $(strip $1) $(strip $2)
endef #sm.tool.gcc.compile.asm.unchecked

##
##
##
define sm.tool.gcc.compile
$(if $1,,$(error smart: arg \#1 must be the source language))\
$(if $2,,$(error smart: arg \#2 must be the output target))\
$(if $3,,$(error smart: arg \#3 must be the source file))\
$(call sm.tool.gcc.compile.$(strip $1).unchecked,$2,$3)
endef #sm.tool.gcc.compile

sm.tool.gcc.compile.c = $(call sm.tool.gcc.compile,c,$1,$2)
sm.tool.gcc.compile.c++ = $(call sm.tool.gcc.compile,c++,$1,$2)
sm.tool.gcc.compile.asm = $(call sm.tool.gcc.compile,asm,$1,$2)


##################################################
# Links

##
##
##
define sm.tool.gcc.link.c
$(sm.tool.gcc.cmd.cc) -o $(strip $1) $(strip $2)
endef #sm.tool.gcc.link.c

##
##
##
define sm.tool.gcc.link.c++
$(sm.tool.gcc.cmd.c++) -o $(strip $1) $(strip $2)
endef #sm.tool.gcc.link.c++

##
##
##
define sm.tool.gcc.link.asm
$(sm.tool.gcc.cmd.as) -o $(strip $1) $(strip $2)
endef #sm.tool.gcc.link.asm

##
##
##
define sm.tool.gcc.link
$(sm.tool.gcc.cmd.ld) -o $(strip $1) $(strip $2)
endef

