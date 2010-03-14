# -*- mode: Makefile:gnu -*-
#	Copyright(c) 2009, by Zhan Xin-ming, duzy@duzy.info
#	

# Check make version
$(info TODO: check $$(MAKE_VERSION))

SHELL := /bin/bash

## Smart Build directory, internal use only, must always contain a '/' tail.
sm_build_dir := $(patsubst %/,%,$(dir $(lastword $(MAKEFILE_LIST))))

ifeq ($(sm_build_dir)/defuns.mk,)
  $(error "Can't find smart build system directory.")
else
  # Predefined functions.
  include $(sm_build_dir)/defuns.mk
endif

ifeq ($(sm_build_dir)/conf.mk,)
  $(error "Can't find smart build system directory.")
else
  # Automate configuration for build parameters.
  include $(sm_build_dir)/conf.mk
endif

.DEFAULT_GOAL := build-goals

##################################################

_sm_mods := $(wildcard $(SM_TOP_DIR)/smart.mk)
#_sm_mods += $(call sm-find-sub-modules, $(SM_TOP_DIR))

ifneq ($(_sm_mods),)
  SM_GLOBAL_GOALS :=
  SM_GLOBAL_MODULE_NAMES :=
  $(foreach v,$(_sm_mods),$(eval $$(call load-module,$v)))
  $(foreach v,$(SM_GLOBAL_MODULE_NAMES),$(info smart: New module '$v'))
else
  $(info smart: ************************************************************)
  $(info smart:  You have to provide the root build script 'smart.mk' at top)
  $(info smart:  level directory of the project.)
  $(info smart: ************************************************************)
  $(error "Can't find the root build script 'smart.mk'.")
endif

.PHONY: build-goals
ifneq ($(SM_GLOBAL_GOALS),)
  build-goals: $(SM_GLOBAL_GOALS)
else
  build-goals:; $(info smart: No goals.) @true
endif

_sm_mods :=

