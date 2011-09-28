# -*- mode: Makefile:gnu -*-
#	Copyright(c) 2009-2010, by Zhan Xin-ming, code@duzy.info
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
  $(info smart:  I cannot calculate the value of top level directory.)
  $(info smart: ************************************************************)
  $(error Cannot detect the value of project top level directory.)
endif

## alias
sm.dir.top = $(call sm-deprecated, sm.dir.top, sm.top)

## The output dirs for intermediates.
## These will always be converted into sm.top related path, this will restrict
## the command line arguments length.
#sm.out = $(if $(sm.this.toolset),,$(error smart: sm.this.toolset not set)\
#  )out/$(if $(sm.this.toolset),$(sm.this.toolset)/)$(sm.config.variant)
sm.out = out/$(if $(sm.this.toolset),$(sm.this.toolset)/)$(sm.config.variant)
sm.out.bin = $(sm.out)/bin
sm.out.lib = $(sm.out)/lib
sm.out.inc = $(sm.out)/include
sm.out.obj = $(sm.out)/obj
sm.out.tmp = $(sm.out)/temp
sm.out.inter = $(sm.out)/intermediates
#sm.out.doc = out/$(sm.config.variant)/documents
sm.out.doc = out/documents

sm.dir.out = $(call sm-deprecated, sm.dir.out, sm.out)
sm.dir.out.bin = $(call sm-deprecated, sm.dir.out.bin, sm.out.bin)
sm.dir.out.lib = $(call sm-deprecated, sm.dir.out.lib, sm.out.lib)
sm.dir.out.inc = $(call sm-deprecated, sm.dir.out.inc, sm.out.inc)
sm.dir.out.obj = $(call sm-deprecated, sm.dir.out.obj, sm.out.obj)
sm.dir.out.tmp = $(call sm-deprecated, sm.dir.out.tmp, sm.out.tmp)

# The variant of this building.
ifeq ($(strip $(sm.config.variant)),)
  ifneq ($(strip $V),)
    sm.config.variant := $V
  else
    sm.config.variant := debug
  endif
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
  sm.os.name.win32.mingw32 := true
endif

# ## The default toolset is 'gcc'
# ifeq ($(origin toolset),command line)
#   sm.toolset := $(or $(toolset),gcc)
# else
#   sm.toolset := gcc
# endif

include $(sm.dir.buildsys)/tools/common.mk

sm.log.enabled :=
sm.log.filename :=

sm.global.libdirs :=
sm.global.includes :=
sm.global.libs :=
sm.global.compile.flags :=
sm.global.archive.flags :=
sm.global.link.flags :=
sm.global.module_types := static shared executable exe tests t docs depends

ifeq ($(sm.config.variant),debug)
  sm.global.compile.flags += -g -ggdb
endif
ifeq ($(sm.config.variant),release)
  sm.global.compile.flags += -O2
endif

sm.var.Q := @
