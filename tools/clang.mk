# -*- mode: Makefile:gnu -*-
#	Copyright(c) 2009-2010, by Zhan Xin-ming, duzy@duzy.info
#	

##
##  sm.toolset.clang
##

## make sure that clang.mk is included only once
$(call sm-check-origin, sm.tool.clang, undefined)

sm.tool.clang := true

sm.tool.clang.cmd.cc := clang
sm.tool.clang.cmd.c++ := clang++
sm.tool.clang.cmd.asm := gas
sm.tool.clang.cmd.ll := llvmc
sm.tool.clang.cmd.ld := ld
sm.tool.clang.cmd.ar := ar crs

sm.tool.clang.langs := c c++ ll
sm.tool.clang.c.suffix :=
sm.tool.clang.c++.suffix :=
sm.tool.clang.ll.suffix :=

######################################################################
# Compilation

define sm.tool.clang.compile.c
$(sm.tool.clang.cmd.cc) $($(strip $3)) -c -o $(strip $1) $(strip $2)
endef #sm.tool.clang.compile.c

define sm.tool.clang.compile.c++
$(sm.tool.clang.cmd.c++) $($(strip $3)) -c -o $(strip $1) $(strip $2)
endef #sm.tool.clang.compile.c++

define sm.tool.clang.compile.asm
$(sm.tool.clang.cmd.asm) $($(strip $3)) -c -o $(strip $1) $(strip $2)
endef #sm.tool.clang.compile.asm

define sm.tool.clang.compile.ll
$(sm.tool.clang.cmd.ll) $($(strip $3)) -c -o $(strip $1) $(strip $2)
endef #sm.tool.clang.compile.ll

# TODO: ...
