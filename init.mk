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
sm.config.variant := debug
sm.config.uname := $(shell uname)


sm.os.name :=
sm.os.name.linux :=
sm.os.name.win32 :=
ifeq ($(sm.config.uname),Linux)
  sm.os.name := linux
  sm.os.name.linux := true
endif
ifeq ($(sm.config.uname),MinGW)
  sm.os.name := win32
  s.mos.name.win32 := true
endif


sm.log.enabled :=
sm.log.filename :=

sm.global.dirs.lib :=
sm.global.includes :=
sm.global.libs :=
sm.global.options.compile :=
sm.global.options.link :=
sm.global.module_types := static shared executable
