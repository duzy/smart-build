# -*- mode: Makefile:gnu -*-
#	Copyright(c) 2009, by Zhan Xin-ming, code@duzy.info
#	

# Check make version
sm.make.version.compatible := 3.80 3.81
ifeq ($(filter $(MAKE_VERSION),$(sm.make.version.compatible)),)
  $(error "smart: Unsupported GNU/Make version, expect for: $(sm.make.version.compatible)")
endif

## Smart Build directory, internal use only, must always contain a '/' tail.
sm.dir.buildsys := $(patsubst %/,%,$(dir $(lastword $(MAKEFILE_LIST))))

SHELL := /bin/bash

ifeq ($(wildcard $(sm.dir.buildsys)/defuns.mk),)
  $(error "smart: Can't find smart build system directory.")
else
  # Predefined functions.
  include $(sm.dir.buildsys)/defuns.mk
endif

ifeq ($(wildcard $(sm.dir.buildsys)/init.mk),)
  $(error "smart: can't find smart build system directory")
else
  # Variables of 'sm.*' spec
  include $(sm.dir.buildsys)/init.mk
endif

ifeq ($(wildcard $(sm.dir.buildsys)/rules.mk),)  # funs for gen rules
  $(error "smart: can't find smart build system directory")
else
  include $(sm.dir.buildsys)/rules.mk
endif

ifeq ($(wildcard $(sm.dir.buildsys)/conf.mk),)
  $(error "smart: Can't find smart build system directory.")
else
  # Automate configuration for build parameters.
  include $(sm.dir.buildsys)/conf.mk
endif

.DEFAULT_GOAL := all

##################################################

sm.global.smartfiles.toplevel := $(wildcard $(sm.top)/smart.mk)

ifneq ($(strip $(sm.global.smartfiles.toplevel)),)
  sm.global.goals :=
  sm.global.modules :=
  $(foreach v,$(sm.global.smartfiles.toplevel),$(eval $$(call sm-load-module,$v)))
  #$(foreach v,$(sm.global.modules),$(info smart: module '$v' by $(sm.global.modules.$v)))
else
  $(info smart: ************************************************************)
  $(info smart:  You have to provide the root build script 'smart.mk' at top)
  $(info smart:  level directory of the project.)
  $(info smart: ************************************************************)
  $(error Can't find the root build script 'smart.mk') #'
endif

# .PRECIOUS: foo bar
# .DELETE_ON_ERROR: foo bar

.PHONY: all clean test $(sm.rules.phony.*)
ifneq ($(sm.global.goals),)
  all: $(sm.global.goals)
  clean: $(sm.global.goals:goal-%=clean-%)

  ifneq ($(sm.global.tests),)
    test: $(sm.global.tests)
  endif

  $(call sm-check-not-empty, sm.out)
  $(call sm-check-not-empty, sm.out.bin)
  $(call sm-check-not-empty, sm.out.lib)
  $(call sm-check-not-empty, sm.out.inc)
  $(call sm-check-not-empty, sm.out.obj)
  $(call sm-check-not-empty, sm.out.tmp)

  ## rules for output dirs, TODO: replace sm-util-mkdir on these dirs with it
  $(sm.out) \
  $(sm.out.bin) \
  $(sm.out.lib) \
  $(sm.out.inc) \
  $(sm.out.obj) \
  $(sm.out.tmp) \
  :; $(call sm-util-mkdir,$@) @true

else
  all:; $(info smart: no goals) @true
  clean:; $(info smart: nothing dirty) @true
  test:; $(info smart: no tests) @true
endif

## This duplicated to prevent unexpected changes of it
.DEFAULT_GOAL := all

