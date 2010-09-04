# -*- mode: Makefile:gnu -*-
#	Copyright(c) 2009-2010, by Zhan Xin-ming, duzy@duzy.info
#	

ifneq ($(origin sm-new-module),file)
 $(error "smart: Must include defuns before init.")
endif

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
 $(error "smart: 'sm-register-sources' unsafe: '$(sm-register-sources)'")
else
 $(call sm-register-sources, c++, gcc, .cpp .c++ .cc .CC .C)
 $(call sm-register-sources, asm, gcc, .s .S)
 $(call sm-register-sources, c,   gcc, .c)
 $(call sm-check-equal,$(sm.tool.gcc),true)
 $(call sm-check-value, sm.toolset.for.cpp, gcc)
 $(call sm-check-value, sm.toolset.for.c++, gcc)
 $(call sm-check-value, sm.toolset.for.cc,  gcc)
 $(call sm-check-value, sm.toolset.for.CC,  gcc)
 $(call sm-check-value, sm.toolset.for.C,   gcc)
 $(call sm-check-value, sm.toolset.for.s,   gcc)
 $(call sm-check-value, sm.toolset.for.S,   gcc)
 $(call sm-check-value, sm.toolset.for.c,   gcc)
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
