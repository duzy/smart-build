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

sm.tool.clang.langs := c++ c asm ll
sm.tool.clang.suffix.c := .c
sm.tool.clang.suffix.c++ := .cpp .c++ .cc .CC .C
sm.tool.clang.suffix.asm := .s .S
sm.tool.clang.suffix.ll := .ll

## Compilation output files(objects) suffixes.
sm.tool.clang.suffix.intermediate.c := .o
sm.tool.clang.suffix.intermediate.c++ := .o
sm.tool.clang.suffix.intermediate.asm := .o
sm.tool.clang.suffix.intermediate.ll := .o

## Target link output file suffix.
sm.tool.clang.suffix.target.static.win32 := .a
sm.tool.clang.suffix.target.shared.win32 := .so
sm.tool.clang.suffix.target.exe.win32 := .exe
sm.tool.clang.suffix.target.t.win32 := .test.exe
sm.tool.clang.suffix.target.depends.win32 :=
sm.tool.clang.suffix.target.static.linux := .a
sm.tool.clang.suffix.target.shared.linux := .so
sm.tool.clang.suffix.target.exe.linux :=
sm.tool.clang.suffix.target.t.linux := .test
sm.tool.clang.suffix.target.depends.linux :=

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
$(sm.tool.clang.cmd.c) -MM -MT $(sm.args.target) $(sm.args.flags.0) $(sm.args.sources) \
  > $(sm.args.output)
endef

define sm.tool.clang.dependency.c++
$(sm.tool.clang.cmd.c++) -MM -MT $(sm.args.target) $(sm.args.flags.0) $(sm.args.sources) \
  > $(sm.args.output)
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

sm.tool.clang.compile.flags :=
sm.tool.clang.link.flags :=
sm.tool.clang.compile.flags.c++ := -stdlib=libc++
sm.tool.clang.link.flags.c++ := -stdlib=libc++

ifeq ($(strip $(sm.config.variant)),debug)
  sm.tool.clang.compile.flags += -g -ggdb
  sm.tool.clang.link.flags +=
else
ifeq ($(strip $(sm.config.variant)),release)
  sm.tool.clang.compile.flags += -O3
  sm.tool.clang.link.flags +=
endif
endif
