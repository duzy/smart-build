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
  $(error Invalid installed build system)
endif

ifeq ($(sm.module.type),subdirs)
  $(error smart: Please try calling 'sm-load-subdirs' instead)
endif

ifneq ($(filter $(sm.module.type),$(sm.global.module_types)),)
  $(call sm-var-temp, _out_bin, :=,$(call sm-to-relative-path,$(sm.dir.out.bin)))
  $(call sm-var-temp, _out_lib, :=,$(call sm-to-relative-path,$(sm.dir.out.lib)))
  $(call sm-var-temp, _g, :=,$(sm.module.name)$(sm.module.suffix))

  ifeq ($(sm.module.type),static)
    ifeq ($(sm.module.suffix),.a)
      ifneq ($(sm.var.temp._g:lib%=ok),ok)
        sm.var.temp._g := lib$(sm.var.temp._g)
      endif
    endif
    sm.var.temp._g := $(sm.var.temp._out_lib)/$(sm.var.temp._g)
  else
    sm.var.temp._g := $(sm.var.temp._out_bin)/$(sm.var.temp._g)
  endif

  goal-$(sm.module.name):$(sm.module.depends) $(sm.module.depends.copy) $(sm.var.temp._g)
  include $(sm.dir.buildsys)/module.mk
else
  $(warning smart: $(sm.module.name) will not be built)
endif

$(sm-var-temp-clean)
