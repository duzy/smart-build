# -*- mode: Makefile:gnu -*-
#	Copyright(c) 2009, by Zhan Xin-ming, duzy@duzy.info
#

# Build the current module according to these macros:
#	sm.module.type		: the type of the module to be compiled
#	sm.module.name		: the name of the module to be compiled
#	sm.module.depends	: module depends on something to build,
#				: the dependences must exists first.
#				

ifeq ($(wildcard $(sm.dir.buildsys)),)
  $(info smart: Cannot locate the build system directory('sm.dir.buildsys').)
  $(error smart: Invalid installed build system)
endif

ifeq ($(sm.module.type),dynamic)
  $(warning Module type 'dynamic' is deprecated, use 'shared' instead!)
  sm.module.type := shared
endif

ifeq ($(sm.module.type),subdirs)
  $(error smart: Please try calling 'sm-load-sub-modules' instead)
endif

_do_building := true
ifneq ($(sm.module.type),static)
  ifneq ($(sm.module.type),shared)
    ifneq ($(sm.module.type),executable)
      # $(info smart: You have to specify 'sm.module.type', it can be one of )
      # $(info smart: '$(sm.module.types_supported)'.)
      # $(error sm.module.type unknown: '$(sm.module.type)'.)
      _do_building := false
    endif
  endif
endif

ifeq ($(_do_building),true)
  ifeq ($(sm.module.type),static)
    g := $(sm.dir.out.lib)/$(sm.module.name)$(sm.module.suffix)
  else
    g := $(sm.dir.out.bin)/$(sm.module.name)$(sm.module.suffix)
  endif
  goal-$(sm.module.name):$(sm.module.depends) $g
  g :=
  include $(sm.dir.buildsys)/module.mk
else
  $(warning smart: $(sm.module.name) will not be built)
endif
