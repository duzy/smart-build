# -*- mode: Makefile:gnu -*-
#	Copyright(c) 2009, by Zhan Xin-ming, duzy@duzy.info
#	

## This file is expected to be included in build/main.mk, and before any
## other files to be included.

# Load default build parameters.
ifeq ($(strip $(sm.this.toolset)),)
  include $(sm.dir.buildsys)/old/defparams.mk
endif

d := $(sm.out)
ifeq ($d,)
  $(info smart: ************************************************************)
  $(info smart:  The top level output directory is empty, maybe you changed)
  $(info smart:  the value of variable 'sm.out' by mistaken.)
  $(info smart: ************************************************************)
  $(error "Top level output directory is empty.")
endif

# Detect custome config file and apply it.
ifneq ($(wildcard $(sm.top)/custom-config),)
  $(info smart: applying custom config...)
  $(eval -include $(sm.top)/custom-config)
endif

