# -*- mode: Makefile:gnu -*-
#	Copyright(c) 2009, by Zhan Xin-ming, duzy@duzy.info
#	

# Check make version
$(info TODO: check $$(MAKE_VERSION))

SHELL := /bin/bash

## Smart Build directory, internal use only, must always contain a '/' tail.
sm.dir.buildsys := $(patsubst %/,%,$(dir $(lastword $(MAKEFILE_LIST))))

ifeq ($(sm.dir.buildsys)/defuns.mk,)
  $(error "Can't find smart build system directory.")
else
  # Predefined functions.
  include $(sm.dir.buildsys)/defuns.mk
endif

ifeq ($(sm.dir.buildsys)/conf.mk,)
  $(error "Can't find smart build system directory.")
else
  # Automate configuration for build parameters.
  include $(sm.dir.buildsys)/conf.mk
endif

.DEFAULT_GOAL := build-goals

##################################################

_sm_mods := $(wildcard $(sm.dir.top)/smart.mk)
#_sm_mods += $(call sm-find-sub-modules, $(sm.dir.top))

ifneq ($(_sm_mods),)
  sm.global.goals :=
  sm.global.module.names :=
  $(foreach v,$(_sm_mods),$(eval $$(call load-module,$v)))
  $(foreach v,$(sm.global.module.names),$(info smart: New module '$v'))
else
  $(info smart: ************************************************************)
  $(info smart:  You have to provide the root build script 'smart.mk' at top)
  $(info smart:  level directory of the project.)
  $(info smart: ************************************************************)
  $(error "Can't find the root build script 'smart.mk'.")
endif

.PHONY: build-goals
ifneq ($(sm.global.goals),)
  build-goals: $(sm.global.goals)
else
  build-goals:; $(info smart: No goals.) @true
endif

_sm_mods :=

