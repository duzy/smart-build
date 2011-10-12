# -*- mode: Makefile:gnu -*-
#	Copyright(c) 2009, by Zhan Xin-ming, code@duzy.info
#

# Build the current module according to these macros:
#	sm.this.type		: the type of the module to be compiled
#	sm.this.name		: the name of the module to be compiled
#	sm.this.depends		: this module depends on other targets,
#				: the dependences must exists first.
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

ifneq ($(filter $($(sm._this).type),$(sm.global.module_types)),)
  sm.global.goals += goal-$($(sm._this).name)

  # this duplicats in 'sm-build-this'
  #$(sm._this)._cnum := 0

  include $(sm.dir.buildsys)/build-rules.mk

  $(sm._this)._already_built := true
else
  $(warning smart: "$($(sm._this).name)" will not be built)
endif
