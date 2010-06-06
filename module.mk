# -*- mode: Makefile:gnu -*-
#	Copyright(c) 2009, by Zhan Xin-ming, duzy@duzy.info
#

# Build the current 'binary' module according to these macros:
#	sm.log.filename		: log filename(relative) of compile commands
#	sm.module.dir		: the directory in which the module locates
#	sm.module.type		: the type of the module to be compiled
#	sm.module.name		: the name of the module to be compiled
#	sm.module.suffix	: the suffix of the module name(.exe, .so, .dll, etc.)
#	sm.module.sources	: the sources to be compiled into the module
#	sm.module.sources.generated	: the local generated sources to be compiled into the module
#	sm.module.headers	: (unused)
#
#	sm.module.out_implib	: --out-implib to linker on Win32, for shared
#				: module
#	
#	sm.module.dirs.include	: include pathes for compiling the module
#	sm.module.options.compile : module specific compile flags
#	sm.module.options.compile.infile
#	sm.module.options.link	: module link flags
#	sm.module.options.link.infile
#	sm.module.dirs.lib	: the search path of libs the module links to
#	sm.module.libs		: libs (-l switches) the module links to
#	sm.module.whole_archives: .a archives to be pulled into a shared
#				: libraries as a whole, see --whole-archive.
#	sm.module.prebuilt_objects: prebuilt objects
#
#	sm.module.rpath		: -rpath
#	sm.module.rpath-link	: -rpath-link
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

ifeq ($(sm.module.type),dynamic)
  sm.module.type := shared
endif

ifneq ($(sm.module.includes),)
  $(warning sm.module.includes is deprecated, use sm.module.dirs.include instead)
  sm.module.dirs.include := $(sm.module.includes) $(sm.module.dirs.include)
endif

ifneq ($(sm.global.includes),)
  $(warning sm.global.includes is deprecated, use sm.global.dirs.include instead)
  sm.global.dirs.include := $(sm.global.includes) $(sm.global.dirs.include)
endif

ifeq ($(sm.module.name),)
  $(info smart: You have to specify 'sm.module.name'.)
  $(error sm.module.name unknown)
endif

ifeq ($(filter $(sm.module.type),$(sm.global.module_types)),)
  $(info smart: You have to specify 'sm.module.type', it can be one of )
  $(info smart: '$(sm.module.types_supported)'.)
  $(error sm.module.type unknown: '$(sm.module.type)'.)
endif

ifndef sm-to-relative-path
  $(error sm-to-relative-path undefined)
endif

## Compile log command.
_sm_log = $(if $(sm.log.filename),\
    echo $1 >> $(sm.dir.out)/$(sm.log.filename),true)

_sm_has_sources.asm :=
_sm_has_sources.c :=
_sm_has_sources.c++ :=
_sm_has_sources.h :=

ifneq ($(strip $(sm.module.sources) $(sm.module.sources.generated)),)
  include $(sm.dir.buildsys)/objrules.mk
else
  ifeq ($(strip $(sm.module.objects)),)
    $(error Nothing to build, no sources or objects for $(sm.module.name))
  endif
endif

ifeq ($(sm.module.type),static)
  include $(sm.dir.buildsys)/archive.mk
else
  include $(sm.dir.buildsys)/binary.mk
endif

s :=
d :=
r :=

