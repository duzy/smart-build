# -*- mode: Makefile:gnu -*-
#	Copyright(c) 2009, by Zhan Xin-ming, duzy@duzy.info
#

# Build the current 'binary' module according to these macros:
#	sm.log.filename		: log filename(relative) of compile commands
#	sm.this.dir		: the directory in which the module locates
#	sm.this.type		: the type of the module to be compiled
#	sm.this.name		: the name of the module to be compiled
#	sm.this.suffix	: the suffix of the module name(.exe, .so, .dll, etc.)
#	sm.this.sources	: the sources to be compiled into the module
#	sm.this.sources.external	: the local generated sources to be compiled into the module
#	sm.this.headers	: (unused)
#
#	sm.this.out_implib	: --out-implib to linker on Win32, for shared
#				: module
#	
#	sm.this.includes	: include pathes for compiling the module
#	
#	sm.this.compile.options, sm.this.compile.flags
#				: module specific compile flags
#	
#	sm.this.compile.options.infile, sm.this.compile.flags.infile
#				: put compile options/flags into temp file
#	
#	sm.this.link.options, sm.this.link.flags
#				: module link flags
#	
#	sm.this.link.options.infile, sm.this.link.flags.infile
#				: put link options/flags into temp file
#	
#	sm.this.libdirs	: the search path of libs the module links to
#	sm.this.libs		: libs (-l switches) the module links to
#	sm.this.whole_archives: .a archives to be pulled into a shared
#				: libraries as a whole, see --whole-archive.
#	sm.this.prebuilt_objects: prebuilt objects
#
#	sm.this.rpath		: -rpath
#	sm.this.rpath-link	: -rpath-link
#	
#	sm.global.includes	:
#	sm.global.compile.options, sm.global.compile.flags
#				:
#	sm.global.link.options, sm.global.link.flags
#				:
#	sm.global.libdirs	:
#	sm.global.libs		:
#
#	sm.out
#	sm.out.bin
#	sm.out.lib
#	sm.out.obj
#	

$(if $(strip $(sm.this.dir)),,$(error 'sm.this.dir' must be set))

ifneq ($(sm.global.options.compile)$(sm.this.options.compile),)
  $(error 'sm.*.options.compile' is deprecated, use 'sm.*.compile.options' or 'sm.*.compile.flags' instead)
endif

ifneq ($(sm.global.options.link)$(sm.this.options.link),)
  $(error 'sm.*.options.link' is deprecated, use 'sm.global.link.options' or 'sm.*.link.flags' instead)
endif

ifneq ($(sm.this.options.compile.infile)$(sm.this.options.link.infile),)
  $(error 'sm.this.options.*.infile' is deprecated, use 'sm.this.*.options.infile' or 'sm.this.*.flags.infile' instead)
endif

ifneq ($(sm.global.dirs.include)$(sm.this.dirs.include),)
  $(error 'sm.*.dirs.include' is deprecated, use 'sm.*.includes' instead)
endif

ifneq ($(sm.global.dirs.lib)$(sm.this.dirs.lib),)
  $(error 'sm.*.dirs.lib' is deprecated, use 'sm.*.libdirs' instead)
endif

ifeq ($(sm.this.name),)
  $(info smart: You have to specify 'sm.this.name'.)
  $(error sm.this.name unknown)
endif

ifeq ($(filter $(sm.this.type),$(sm.global.module_types)),)
  $(info smart: You have to specify 'sm.this.type', it can be one of )
  $(info smart: '$(sm.this.types_supported)'.)
  $(error sm.this.type unknown: '$(sm.this.type)'.)
endif

ifndef sm-to-relative-path
  $(error sm-to-relative-path undefined)
endif

## Compile log command.
_sm_log = $(if $(sm.log.filename),\
    echo $1 >> $(sm.out)/$(sm.log.filename),true)

_sm_has_sources.asm :=
_sm_has_sources.c :=
_sm_has_sources.c++ :=
_sm_has_sources.h :=

ifneq ($(strip $(sm.this.sources) $(sm.this.sources.external)),)
  include $(sm.dir.buildsys)/old/objrules.mk
else
  ifeq ($(strip $(sm.this.objects)),)
    $(error No sources or objects for $(sm.this.name))
  endif
endif

ifeq ($(sm.this.type),static)
  include $(sm.dir.buildsys)/old/archive.mk
else
  include $(sm.dir.buildsys)/old/binary.mk
endif

s :=
d :=
r :=

