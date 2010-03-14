# -*- mode: Makefile:gnu -*-
#	Copyright(c) 2009, by Zhan Xin-ming, duzy@duzy.info
#

# Build the current module according to these macros:
#	SM_MODULE_TYPE		: the type of the module to be compiled
#	SM_MODULE_NAME		: the name of the module to be compiled
#	SM_MODULE_DEPENDS	: module depends on something to build,
#				: the dependences must exists first.
#				

ifeq ($(wildcard $(sm_build_dir)),)
  $(info smart: Cannot locate the build system directory('sm_build_dir').)
  $(error Invalid installed build system)
endif

ifeq ($(SM_MODULE_TYPE),subdirs)
  $(error smart: Please try calling 'sm-load-sub-modules' instead)
endif

_do_building := true
ifneq ($(SM_MODULE_TYPE),static)
  ifneq ($(SM_MODULE_TYPE),dynamic)
    ifneq ($(SM_MODULE_TYPE),executable)
      # $(info smart: You have to specify 'SM_MODULE_TYPE', it can be one of )
      # $(info smart: '$(SM_MODULE_TYPES_SUPPORTED)'.)
      # $(error SM_MODULE_TYPE unknown: '$(SM_MODULE_TYPE)'.)
      _do_building := false
    endif
  endif
endif

ifeq ($(_do_building),true)
  ifeq ($(SM_MODULE_TYPE),static)
    g := $(SM_OUT_DIR_lib)/$(SM_MODULE_NAME)
  else
    g := $(SM_OUT_DIR_bin)/$(SM_MODULE_NAME)
  endif
  goal-$(SM_MODULE_NAME):$(SM_MODULE_DEPENDS) $g
  g :=
  include $(sm_build_dir)/module.mk
else
  $(warning smart: $(SM_MODULE_NAME) will not be built)
endif
