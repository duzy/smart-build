# -*- mode: Makefile:gnu -*-
#	Copyright(c) 2009-2010, by Zhan Xin-ming, duzy@duzy.info
#	

## check origin of 'sm-check-origin' itself
ifneq ($(origin sm-check-origin),file)
  $(error smart: Please load 'build/main.mk' first)
endif

$(call sm-check-origin,sm-new-module,file,Broken smart build system)

# The project top level directory is where you type 'make' in.
sm.top := $(if $(wildcard $(PWD)),$(PWD),$(shell pwd))
ifeq ($(wildcard $(sm.top)),)
  $(info smart: ************************************************************)
  $(info smart:  I can't calculate the value of top level directory.) #'
  $(info smart: ************************************************************)
  $(error Can't detect the value of project top level directory.) #'
endif

## alias
sm.dir.top := $(sm.top)

## The output dirs for objects.
## These will always be converted into sm.top related path, this will restrict
## the command line arguments length.
#sm.dir.out = $(sm.top)/out/$(sm.config.variant)
sm.dir.out = out/$(sm.config.variant)
sm.dir.out.bin = $(sm.dir.out)/bin
sm.dir.out.lib = $(sm.dir.out)/lib
sm.dir.out.inc = $(sm.dir.out)/include
sm.dir.out.obj = $(sm.dir.out)/obj
sm.dir.out.tmp = $(sm.dir.out)/temp


# The variant of this building.
ifeq ($(strip $(sm.config.variant)),)
  sm.config.variant := debug
endif
sm.config.uname := $(shell uname)
sm.config.machine := $(shell uname -m)

sm.os.arch := $(sm.config.machine)
sm.os.name :=
sm.os.name.linux :=
sm.os.name.win32 :=
ifeq ($(sm.config.uname),Linux)
  sm.os.name := linux
  sm.os.name.linux := true
endif
ifneq ($(findstring MINGW32,$(sm.config.uname)),)
  sm.os.name := win32
  sm.os.name.win32 := true
endif

## The default toolset is 'gcc'
sm.toolset := gcc

ifneq ($(origin sm-register-sources),file)
 $(error smart: 'sm-register-sources' unsafe: '$(sm-register-sources)')
else
 include $(sm.dir.buildsys)/tools/common.mk
 $(call sm-register-sources, c++, gcc, .cpp .c++ .cc .CC .C)
 $(call sm-register-sources, asm, gcc, .s .S)
 $(call sm-register-sources, c,   gcc, .c)
 $(call sm-check-equal,$(sm.tool.gcc),true, smart: gcc toolset not well)
 $(call sm-check-value, sm.toolset.for.file.cpp, gcc, smart: gcc toolset ignores .cpp)
 $(call sm-check-value, sm.toolset.for.file.c++, gcc, smart: gcc toolset ignores .c++)
 $(call sm-check-value, sm.toolset.for.file.cc,  gcc, smart: gcc toolset ignores .cc)
 $(call sm-check-value, sm.toolset.for.file.CC,  gcc, smart: gcc toolset ignores .CC)
 $(call sm-check-value, sm.toolset.for.file.C,   gcc, smart: gcc toolset ignores .C)
 $(call sm-check-value, sm.toolset.for.file.s,   gcc, smart: gcc toolset ignores .s)
 $(call sm-check-value, sm.toolset.for.file.S,   gcc, smart: gcc toolset ignores .S)
 $(call sm-check-value, sm.toolset.for.file.c,   gcc, smart: gcc toolset ignores .c)
endif

sm.log.enabled :=
sm.log.filename :=

sm.global.libdirs :=
sm.global.includes :=
sm.global.libs :=
sm.global.compile.flags :=
sm.global.compile.options :=
sm.global.link.flags :=
sm.global.link.options :=
sm.global.module_types := static shared executable exe tests t

sm.var.Q := @

ifeq ($(strip $(sm.config.variant)),debug)
  sm.global.compile.options := -g -ggdb
endif
