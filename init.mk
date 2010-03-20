# -*- mode: Makefile:gnu -*-
#	Copyright(c) 2009-2010, by Zhan Xin-ming, duzy@duzy.info
#	

# The project top level directory is where you type 'make' in.
sm.dir.top := $(if $(PWD),$(PWD),$(shell pwd))
ifeq ($(wildcard $(sm.dir.top)),)
  $(info smart: ************************************************************)
  $(info smart:  I can't calculate the value of top level directory.) #'
  $(info smart: ************************************************************)
  $(error "Can't detect the value of project top level directory.")
endif

# The variant of this building.
sm.config.variant := debug
sm.config.uname := $(shell uname)
sm.config.* := variant uname

sm.os.name := $(shell uname)
sm.os.* := name

# The directory in which the module locates.
sm.module.dir :=

# The type of target which the smart build should generate, available value
# would be: static, shared/dynamic, executable
sm.module.type :=
sm.module.types_supported := static shared executable

# The name of the current compiling module, must be relative names.
sm.module.name :=

# The source file list of the current compiling module, must be relative names.
sm.module.sources :=

sm.module.headers :=

# Compile command log, provide a log name to enable that.
sm.log.filename :=

sm.global.dirs.include :=
sm.global.dirs.lib :=
sm.global.libs :=
sm.global.options.compile :=
sm.global.options.link :=
sm.global.* := \
  dirs \
  libs \
  options \

sm.module.depends :=
sm.module.dir :=
sm.module.dirs.include :=
sm.module.dirs.lib :=
sm.module.headers :=
sm.module.libs :=
sm.module.name :=
sm.module.options.compile :=
sm.module.options.link :=
sm.module.out_implib :=
sm.module.sources :=
sm.module.suffix :=
sm.module.type :=
sm.module.whole_archives :=
sm.module.* := \
  depends \
  dir \
  dirs \
  headers \
  libs \
  name \
  options \
  out_implib \
  sources \
  suffix \
  type \
  whole_archives \

# The ouput directory for generated objects and files.
sm.dir.out = $(sm.dir.top)/out/$(sm.config.variant)
sm.dir.out.bin = $(sm.dir.out)/bin
sm.dir.out.lib = $(sm.dir.out)/lib
sm.dir.out.inc = $(sm.dir.out)/include
sm.dir.out.obj = $(sm.dir.out)/obj
sm.dir.out.tmp = $(sm.dir.out)/temp
sm.dir.out.* := bin lib inc obj tmp
sm.dir.* = top out
## NOTE: sm.dir.buildsys is not included in sm.dir.* variable.
