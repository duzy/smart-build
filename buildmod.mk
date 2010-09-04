# -*- mode: Makefile:gnu -*-
#	Copyright(c) 2009, by Zhan Xin-ming, duzy@duzy.info
#

# Build the current module according to these macros:
#	sm.this.type		: the type of the module to be compiled
#	sm.this.name		: the name of the module to be compiled
#	sm.this.depends	: module depends on something to build,
#				: the dependences must exists first.
#				

ifeq ($(wildcard $(sm.dir.buildsys)),)
  $(info smart: Cannot locate the build system directory('sm.dir.buildsys').)
  $(error Invalid installed build system)
endif

ifeq ($(sm.this.type),subdirs)
  $(error smart: Please try calling 'sm-load-subdirs' instead)
endif

ifneq ($(filter $(sm.this.type),$(sm.global.module_types)),)
  $(call sm-var-temp, _out_bin, :=,$(call sm-to-relative-path,$(sm.dir.out.bin)))
  $(call sm-var-temp, _out_lib, :=,$(call sm-to-relative-path,$(sm.dir.out.lib)))
  $(call sm-var-temp, _g, :=,$(sm.this.name)$(sm.this.suffix))

  ifeq ($(sm.this.type),static)
    ifeq ($(sm.this.suffix),.a)
      ifneq ($(sm.var.temp._g:lib%=ok),ok)
        sm.var.temp._g := lib$(sm.var.temp._g)
      endif
    endif
    sm.var.temp._g := $(sm.var.temp._out_lib)/$(sm.var.temp._g)
  else
    sm.var.temp._g := $(sm.var.temp._out_bin)/$(sm.var.temp._g)
  endif

  goal-$(sm.this.name):$(sm.this.depends) $(sm.this.depends.copy) $(sm.var.temp._g)
  include $(sm.dir.buildsys)/module.mk
else
  $(warning smart: $(sm.this.name) will not be built)
endif

$(sm-var-temp-clean)
