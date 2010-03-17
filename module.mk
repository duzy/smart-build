# -*- mode: Makefile:gnu -*-
#	Copyright(c) 2009, by Zhan Xin-ming, duzy@duzy.info
#

# Build the current 'binary' module according to these macros:
#	SM_COMPILE_LOG		: log filename(relative) of compile commands
#	sm.module.dir		: the directory in which the module locates
#	sm.module.type		: the type of the module to be compiled
#	sm.module.name		: the name of the module to be compiled
#	sm.module.sources	: the sources to be compiled into the module
#	sm.module.headers	: (unused)
#
#	sm.module.out_implib	: --out-implib to linker on Win32, for dynamic
#				: module
#	
#	sm.module.includes	: include pathes for compiling the module
#	sm.module.options.compile : module specific compile flags
#	sm.module.options.link	: module link flags
#	sm.module.dirs.lib	: the search path of libs the module links to
#	sm.module.libs		: libs (-l switches) the module links to
#	sm.module.whole_archives: .a archives to be pulled into a dynamic
#				: libraries as a whole, see --whole-archive.
#	SM_MODULE_PREBUILT_OBJECTS: prebuilt objects
#
#	sm.global.includes	:
#	sm.global.options.compile:
#	sm.global.options.link	:
#	sm.global.dirs.lib	:
#	sm.global.libs		:
#
#	sm.dir.out
#	sm.dir.out.bin
#	sm.dir.out.lib
#	sm.dir.out.obj
#	

$(if $(strip $(sm.module.dir)),,$(error sm.module.dir must be set))

ifeq ($(sm.module.name),)
  $(info smart: You have to specify 'sm.module.name'.)
  $(error sm.module.name unknown)
endif

#d := $(wildcard $(sm.module.sources))
d := $(strip $(sm.module.sources))
ifeq ($d,)
  $(error Nothing to build, no sources)
endif

ifneq ($(sm.module.type),static)
 ifneq ($(sm.module.type),dynamic)
  ifneq ($(sm.module.type),executable)
    $(info smart: You have to specify 'sm.module.type', it can be one of )
    $(info smart: '$(sm.module.types_supported)'.)
    $(error sm.module.type unknown: '$(sm.module.type)'.)
  endif
 endif
endif

## Compile log command.
_sm_log = $(if $(SM_COMPILE_LOG),\
    echo $1 >> $(sm.dir.out)/$(SM_COMPILE_LOG),true)

## Command for making out dir
_sm_mk_out_dir = $(if $(wildcard $1),,$(info mkdir: $1)$(shell mkdir -p $1))

r := $(sm.module.dir:$(sm.dir.top)%=%)

include $(sm.dir.buildsys)/objrules.mk

ifeq ($(sm.module.type),static)
  include $(sm.dir.buildsys)/archive.mk
else
  include $(sm.dir.buildsys)/binary.mk
endif

_sm_objs :=

s :=
d :=
r :=

