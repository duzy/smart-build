# -*- mode: Makefile:gnu -*-
#	Copyright(c) 2009-2010, by Zhan Xin-ming, duzy@duzy.info
#	

##
##  sm.toolset.clang
##

## make sure that clang.mk is included only once
$(call sm-check-origin, sm.tool.clang, undefined)

sm.tool.clang := true

sm.tool.clang.cmd.c := clang
sm.tool.clang.cmd.c++ := clang++
sm.tool.clang.cmd.asm := clang
sm.tool.clang.cmd.ll := llvmc
sm.tool.clang.cmd.ld := clang
sm.tool.clang.cmd.ar := ar crs

sm.tool.clang.langs := c c++ asm ll
sm.tool.clang.c.suffix := .c
sm.tool.clang.c++.suffix := .cpp .c++ .cc .CC .C
sm.tool.clang.asm.suffix := .s .S
sm.tool.clang.ll.suffix := .ll

######################################################################
# Compilation

define sm.tool.clang.compile.c
$(sm.tool.clang.cmd.c) $(strip $3) -c -o $(strip $1) $(strip $2)
endef #sm.tool.clang.compile.c

define sm.tool.clang.compile.c++
$(sm.tool.clang.cmd.c++) $(strip $3) -c -o $(strip $1) $(strip $2)
endef #sm.tool.clang.compile.c++

define sm.tool.clang.compile.asm
$(sm.tool.clang.cmd.asm) $(strip $3) -c -o $(strip $1) $(strip $2)
endef #sm.tool.clang.compile.asm

define sm.tool.clang.compile.ll
$(sm.tool.clang.cmd.ll) $(strip $3) -c -o $(strip $1) $(strip $2)
endef #sm.tool.clang.compile.ll

#

define sm.tool.clang.dependency.c
gcc -MM -MT $(strip $2) -MF $(strip $1) $(strip $4) $(strip $3)
endef

define sm.tool.clang.dependency.c++
g++ -MM -MT $(strip $2) -MF $(strip $1) $(strip $4) $(strip $3)
endef

define sm.tool.clang.dependency.ll
echo TODO:dependency: $1 $2 $3
endef

#

define sm.tool.clang.link.c
$(sm.tool.clang.cmd.c) $(strip $3) -o $(strip $1) $(strip $2) $(strip $4)
endef

define sm.tool.clang.link.c++
$(sm.tool.clang.cmd.c++) $(strip $3) -o $(strip $1) $(strip $2) $(strip $4)
endef

define sm.tool.clang.link.asm
$(sm.tool.clang.cmd.asm) $(strip $3) -o $(strip $1) $(strip $2) $(strip $4)
endef

