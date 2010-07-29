# -*- mode: Makefile:gnu -*-
#	Copyright(c) 2009-2010, by Zhan Xin-ming, duzy@duzy.info
#	

# The project top level directory is where you type 'make' in.
sm.dir.top := $(if $(wildcard $(PWD)),$(PWD),$(shell pwd))
ifeq ($(wildcard $(sm.dir.top)),)
  $(info smart: ************************************************************)
  $(info smart:  I can't calculate the value of top level directory.) #'
  $(info smart: ************************************************************)
  $(error Can't detect the value of project top level directory.) #'
endif

## The output dirs for objects.
## These will always be converted into sm.dir.top related path, this will restrict
## the command line arguments length.
#sm.dir.out = $(sm.dir.top)/out/$(sm.config.variant)
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
