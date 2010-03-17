# -*- mode: Makefile:gnu -*-
#	Copyright(c) 2009, by Zhan Xin-ming, duzy@duzy.info
#	

# The project top level directory is where you type 'make' in.
sm.dir.top := $(if $(PWD),$(PWD),$(shell pwd))
ifeq ($(sm.dir.top),)
  $(info smart: ************************************************************)
  $(info smart:  I can't calculate the value of top level directory.) #'
  $(info smart: ************************************************************)
  $(error "Can't detect the value of project top level directory.")
endif

# The variant of this building.
sm.config.variant := debug
sm.config.uname := $(shell uname)

# The type of the platform the project is built on, the following platform is
# regonized by smart-build system: linux, cygwin, mingw.
SM_PLATFORM_TYPE :=

# The sub-type of the platform the project is built on,
# maybe: debian-5, ubuntu-44, ...
SM_PLATFORM_SUBTYPE :=

# The directory in which the module locates.
sm.module.dir :=

# The type of target which the smart build should generate, available value
# would be: static, dynamic, executable
sm.module.type :=
sm.module.types_supported := static dynamic executable

# The name of the current compiling module, must be relative names.
sm.module.name :=

# The source file list of the current compiling module, must be relative names.
sm.module.sources :=

sm.module.headers :=

# Compile command log, provide a log name to enable that.
SM_COMPILE_LOG :=

sm.module.dir :=
sm.module.type :=
sm.module.name :=
sm.module.sources :=
sm.module.headers :=
sm.module.includes :=
sm.module.options.compile :=
sm.module.options.link :=
sm.module.dirs.lib :=
sm.module.libs :=
sm.module.depends :=
sm.global.includes :=
sm.global.options.compile :=
sm.global.options.link :=
sm.global.dirs.lib :=
sm.global.libs :=

# The ouput directory for generated objects and files.
sm.dir.out = $(sm.dir.top)/out/$(sm.config.variant)
sm.dir.out.bin = $(sm.dir.out)/bin
sm.dir.out.lib = $(sm.dir.out)/lib
sm.dir.out.inc = $(sm.dir.out)/include
sm.dir.out.obj = $(sm.dir.out)/obj

CC = gcc
CP = cp
PERL = perl
ASM = as
