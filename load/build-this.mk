# -*- mode: Makefile:gnu -*-
#	Copyright(c) 2009, by Zhan Xin-ming, code@duzy.info
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
  $(error smart: please try calling 'sm-load-subdirs' instead for 'subdirs')
endif

ifneq ($(filter $(sm.this.type),$(sm.global.module_types)),)
  ifeq ($(strip $(sm.this.type)),depends)
    goal-$(sm.this.name) : $(sm.this.depends) $(sm.this.depends.copyfiles)
    clean-$(sm.this.name):
	$(call sm.tool.common.rm, $(sm.this.depends) $(sm.this.depends.copyfiles))
  else
    ifeq ($(strip $(sm.this.toolset)),)
      $(error smart: 'sm.this.toolset' is empty)
    endif

    # this duplicats in 'sm-build-this'
    sm.var._module_compile_num := 0

    include $(sm.dir.buildsys)/build-rules.mk
  endif
else
  $(warning smart: $(sm.this.name) will not be built)
endif
