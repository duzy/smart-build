# -*- mode: Makefile:gnu -*-
#	Copyright(c) 2009, by Zhan Xin-ming, duzy@duzy.info
#

# Build the current 'binary' module according to these macros:
#	SM_COMPILE_LOG		: log filename(relative) of compile commands
#	SM_MODULE_DIR		: the directory in which the module locates
#	SM_MODULE_TYPE		: the type of the module to be compiled
#	SM_MODULE_NAME		: the name of the module to be compiled
#	SM_MODULE_SOURCES	: the sources to be compiled into the module
#	SM_MODULE_HEADERS	: (unused)
#
#	SM_MODULE_OUT_IMPLIB	: --out-implib to linker on Win32, for dynamic
#				: module
#	
#	SM_MODULE_INCLUDES	: include pathes for compiling the module
#	SM_MODULE_COMPILE_FLAGS : module specific compile flags
#	SM_MODULE_LINK_FLAGS	: module link flags
#	SM_MODULE_LIB_DIRS	: the search path of libs the module links to
#	SM_MODULE_LIBS		: libs (-l switches) the module links to
#	SM_MODULE_WHOLE_ARCHIVES: .a archives to be pulled into a dynamic
#				: libraries as a whole, see --whole-archive.
#	SM_MODULE_PREBUILT_OBJECTS: prebuilt objects
#
#	SM_GLOBAL_INCLUDES	:
#	SM_GLOBAL_COMPILE_FLAGS	:
#	SM_GLOBAL_LINK_FLAGS	:
#	SM_GLOBAL_LIB_DIRS	:
#	SM_GLOBAL_LIBS		:
#
#	SM_OUT_DIR
#	SM_OUT_DIR_bin
#	SM_OUT_DIR_lib
#	SM_OUT_DIR_obj
#	

$(if $(strip $(SM_MODULE_DIR)),,$(error SM_MODULE_DIR must be set))

ifeq ($(SM_MODULE_NAME),)
  $(info smart: You have to specify 'SM_MODULE_NAME'.)
  $(error SM_MODULE_NAME unknown)
endif

#d := $(wildcard $(SM_MODULE_SOURCES))
d := $(strip $(SM_MODULE_SOURCES))
ifeq ($d,)
  $(error Nothing to build, no sources)
endif

ifneq ($(SM_MODULE_TYPE),static)
 ifneq ($(SM_MODULE_TYPE),dynamic)
  ifneq ($(SM_MODULE_TYPE),executable)
    $(info smart: You have to specify 'SM_MODULE_TYPE', it can be one of )
    $(info smart: '$(SM_MODULE_TYPES_SUPPORTED)'.)
    $(error SM_MODULE_TYPE unknown: '$(SM_MODULE_TYPE)'.)
  endif
 endif
endif

## Compile log command.
_sm_log = $(if $(SM_COMPILE_LOG),\
    echo $1 >> $(SM_OUT_DIR)/$(SM_COMPILE_LOG),true)

## Command for making out dir
_sm_mk_out_dir = $(if $(wildcard $1),,$(info mkdir: $1)$(shell mkdir -p $1))

r := $(SM_MODULE_DIR:$(SM_TOP_DIR)%=%)

include $(sm_build_dir)/objrules.mk

ifeq ($(SM_MODULE_TYPE),static)
  include $(sm_build_dir)/archive.mk
else
  include $(sm_build_dir)/binary.mk
endif

_sm_objs :=

s :=
d :=
r :=

