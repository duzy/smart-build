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

  include $(sm.dir.buildsys)/rules.mk

  ## make alias to sm.this.sources.LANGs
  ${foreach sm.var.lang, $(sm.var.langs),\
    $(eval sm.this.sources.$(sm.var.lang)          = $$($(sm._this).sources.$(sm.var.lang)))\
    $(eval sm.this.sources.external.$(sm.var.lang) = $$($(sm._this).sources.external.$(sm.var.lang)))\
    $(eval sm.this.sources.has.$(sm.var.lang)      = $$($(sm._this).sources.has.$(sm.var.lang)))\
   }

  ifeq ($($(sm._this).type),t)
    sm.var.lang := $($(sm._this).lang)
    sm.this.sources.$(sm.var.lang).t = $($(sm._this).sources.$(sm.var.lang).t)
    sm.this.sources.external.$(sm.var.lang).t = $($(sm._this).sources.external.$(sm.var.lang).t)
    sm.this.sources.has.$(sm.var.lang).t = $($(sm._this).sources.has.$(sm.var.lang).t)
  endif

  sm.this.lang              = $($(sm._this).lang)
  sm.this.intermediates     = $($(sm._this).intermediates)
  sm.this.inters            = $($(sm._this).intermediates)
  sm.this.depends          := $($(sm._this).depends)
  sm.this.targets          := $($(sm._this).targets)
  sm.this.documents        := $($(sm._this).documents)
  sm.this.sources.common   := $($(sm._this).sources.common)
  sm.this.sources.unknown  := $($(sm._this).sources.unknown)
  sm.this.depends.copyfiles = $($(sm._this).depends.copyfiles)

  $(sm._this)._already_built := true
else
  $(warning smart: "$($(sm._this).name)" will not be built)
endif
