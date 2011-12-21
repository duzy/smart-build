# -*- mode: Makefile:gnu -*-
#	Copyright(c) 2009, by Zhan Xin-ming, code@duzy.info
#
ifeq ($(sm._this),)
  $(error smart: internal: sm._this is empty)
endif

## check origin of 'sm-check-origin' itself
ifneq ($(origin sm-check-origin),file)
  $(error smart: Please load 'build/main.mk' first)
endif

$(call sm-check-origin,sm-check-directory,file,broken smart build system)
$(call sm-check-directory,$(sm.dir.buildsys),broken smart build system)

ifeq ($($(sm._this).name),)
  $(error smart: internal: invalid configured module: $$(sm._this).name is empty)
endif

ifeq ($($(sm._this).type),subdirs)
  $(error smart: please try calling 'sm-load-subdirs' instead for 'subdirs')
endif

sm.goals := $(strip $(sm.goals) goal-$($(sm._this).name))

include $(sm.dir.buildsys)/rules.mk

$(sm._this)._already_built := true

$(call sm-clone-module, $(sm._this), sm.this)
