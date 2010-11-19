# -*- mode: Makefile:gnu -*-
#	Copyright(c) 2009, by Zhan Xin-ming, duzy@duzy.info
#

# Build the current module according to these macros:
#	sm.this.type		: the type of the module to be compiled
#	sm.this.name		: the name of the module to be compiled
#	sm.this.depends		: this module depends on other targets,
#				: the dependences must exists first.
#				

## check origin of 'sm-check-origin' itself
ifneq ($(origin sm-check-origin),file)
  $(error smart: Please load 'build/main.mk' first)
endif

$(call sm-check-origin,sm-check-directory,file,broken smart build system)
$(call sm-check-directory,$(sm.dir.buildsys),broken smart build system)

ifeq ($(sm.this.type),subdirs)
  $(error smart: please try calling 'sm-load-subdirs' instead)
endif

ifneq ($(filter $(sm.this.type),$(sm.global.module_types)),)
  $(call sm-var-temp, _out_bin, :=,$(call sm-to-relative-path,$(sm.out.bin)))
  $(call sm-var-temp, _out_lib, :=,$(call sm-to-relative-path,$(sm.out.lib)))
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

  goal-$(sm.this.name) : $(sm.this.depends) $(sm.this.depends.copyfiles) $(sm.var.temp._g)

  ifeq ($(strip $(sm.this.toolset)),)
    include $(sm.dir.buildsys)/old/module.mk
    clean-$(sm.this.name): ; @echo "TODO: clean $(@:clean-%=%)..."
  else
    # this duplicated in 'sm-build-this'
    sm.var.__module.compile_id := 0
    include $(sm.dir.buildsys)/module.mk
  endif
else
  $(warning smart: $(sm.this.name) will not be built)
endif

$(sm-var-temp-clean)
