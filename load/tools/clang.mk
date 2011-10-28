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

## Compilation output files(objects) suffixes.
sm.tool.clang.intermediate.suffix.c := .o
sm.tool.clang.intermediate.suffix.c++ := .o
sm.tool.clang.intermediate.suffix.asm := .o
sm.tool.clang.intermediate.suffix.ll := .o

## Target link output file suffix.
sm.tool.clang.target.suffix.win32.static := .a
sm.tool.clang.target.suffix.win32.shared := .so
sm.tool.clang.target.suffix.win32.exe := .exe
sm.tool.clang.target.suffix.win32.t := .test.exe
sm.tool.clang.target.suffix.win32.depends :=
sm.tool.clang.target.suffix.linux.static := .a
sm.tool.clang.target.suffix.linux.shared := .so
sm.tool.clang.target.suffix.linux.exe :=
sm.tool.clang.target.suffix.linux.t := .test
sm.tool.clang.target.suffix.linux.depends :=

######################################################################
# Compilation

##
##  Produce compile commands for c language
##
define sm.tool.clang.compile.c.private
$(sm.tool.clang.cmd.c) $(sm.args.flags.0) -c -o $(sm.args.target) $(sm.args.sources)
endef #sm.tool.clang.compile.c.private

##
##
##
define sm.tool.clang.compile.c++.private
$(sm.tool.clang.cmd.c++) $(sm.args.flags.0) -c -o $(sm.args.target) $(sm.args.sources)
endef #sm.tool.clang.compile.c++.private

##
##
##
define sm.tool.clang.compile.asm.private
$(sm.tool.clang.cmd.asm) $(sm.args.flags.0) -c -o $(sm.args.target) $(sm.args.sources)
endef #sm.tool.clang.compile.asm.private

##
##
##
sm.tool.clang.compile     = $(call sm.tool.clang.compile.$(sm.args.lang).private)
sm.tool.clang.compile.c   = $(eval sm.args.lang:=c)$(sm.tool.clang.compile)
sm.tool.clang.compile.c++ = $(eval sm.args.lang:=c++)$(sm.tool.clang.compile)
sm.tool.clang.compile.asm = $(eval sm.args.lang:=asm)$(sm.tool.clang.compile)
sm.tool.clang.compile.ll = $(eval sm.args.lang:=ll)$(sm.tool.clang.compile)

##################################################
# Denpendencies

define sm.tool.clang.dependency.c
gcc -MM -MT $(strip $2) -MF $(strip $1) $(strip $4) $(strip $3)
endef

define sm.tool.clang.dependency.c++
g++ -MM -MT $(strip $2) -MF $(strip $1) $(strip $4) $(strip $3)
endef

define sm.tool.clang.dependency.ll
echo TODO:dependency: $1 $2 $3
endef

##################################################
# Link

define sm.tool.clang.link.c
$(sm.tool.clang.cmd.c) $(sm.args.flags.0) -o $(sm.args.target) $(sm.args.sources) $(sm.args.flags.1)
endef

define sm.tool.clang.link.c++
$(sm.tool.clang.cmd.c++) $(sm.args.flags.0) -o $(sm.args.target) $(sm.args.sources) $(sm.args.flags.1)
endef

define sm.tool.clang.link.asm
$(sm.tool.clang.cmd.asm) $(sm.args.flags.0) -o $(sm.args.target) $(sm.args.sources) $(sm.args.flags.1)
endef

##################################################
# Archive

define sm.tool.clang.archive
$(sm.tool.clang.cmd.ar) $(sm.args.target) $(sm.args.sources)
endef #sm.tool.clang.archive

sm.tool.clang.archive.c   = $(sm.tool.clang.archive)
sm.tool.clang.archive.c++ = $(sm.tool.clang.archive)
sm.tool.clang.archive.asm = $(sm.tool.clang.archive)

######################################################################
# Options

sm.tool.clang.compile.flags := -stdlib=libc++
sm.tool.clang.link.flags := -stdlib=libc++

ifeq ($(strip $(sm.config.variant)),debug)
  sm.tool.clang.compile.flags += -g -ggdb
  sm.tool.clang.link.flags +=
else
ifeq ($(strip $(sm.config.variant)),release)
  sm.tool.clang.compile.flags += -O3
  sm.tool.clang.link.flags +=
endif
endif
