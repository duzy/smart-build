# -*- mode: Makefile:gnu -*-
#	Copyright(c) 2009, by Zhan Xin-ming, duzy@duzy.info
#

#####
# Logic
#####
define equal
$(if $(findstring x$1x,x$2x),true,)
endef
# $(info equal: $(call equal,foo,foo))
# $(info equal: $(call equal,foo, foo))
# $(info equal: $(call equal,foobar,foo))
# $(info equal: $(call equal,foo,foobar))

define not-equal
$(if $(findstring x$1x,x$2x),,true)
endef

define is-true
$(or $(call equal,$1,true),$(call equal,$1,yes))
endef

define is-false
$(if $(call is-true,$1),,true)
endef

#####
# Exported callable macros.
#####
define sm-deprecated
$(error smart: $(strip $1) is deprecated, use $(strip $2) instead)
endef

define sm-this-makefile
$(lastword $(MAKEFILE_LIST))
endef

define sm-this-dir
$(patsubst %/,%,$(dir $(lastword $(MAKEFILE_LIST))))
endef

define sm-module-dir
$(if $(sm.this.name),$(call sm-this-dir),\
  $(error 'sm.this.name' is empty, please use 'sm-this-dir' instead))
endef

define sm-module-type-name
$(if $(call equal,$1,dynamic),shared,\
    $(if $(call equal,$1,executable),exe,\
        $(if $(call equal,$1,tests),t,$1)))
endef

# sm-new-module must be used before any 'include' commands, since
# it invokes sm-module-dir and sm-this-makefile
define sm-new-module
 $(eval \
   sm.this.args.name := $(strip $1)
   sm.this.args.type := $(strip $2)
   sm.this.args.toolset := $(strip $3)
  )\
 $(if $(sm.this.args.name),,$(error module name(as arg 1) required))\
 $(if $(filter $(sm.this.args.name),$(sm.global.modules)),\
     $(error module "$(sm.this.args.name)" already defined in $(sm.global.modules.$(sm.this.args.name))))\
 $(eval \
   sm.this.name := $(basename $(sm.this.args.name))
   sm.this.suffix := $(suffix $(sm.this.args.name))
   sm.this.dir := $$(call sm-module-dir)
   sm.this.makefile := $$(call sm-this-makefile)
   sm.this.gen_deps := true
   sm.global.modules += $(sm.this.args.name)
   sm.global.modules.$(sm.this.args.name) := $$(sm.this.makefile)
  )\
 $(if $(sm.this.name),,$(error module name is empty))\
 $(eval \
   sm.this.type := $(call sm-module-type-name,$(sm.this.args.type))
   ifeq ($$(sm.this.type),shared)
     sm.this.out_implib := $(sm.this.name)
   endif
   ifeq ($$(sm.this.type),docs)
     sm.this.args.toolset := common
   endif
  )\
 $(if $(filter $(sm.this.type),$(sm.global.module_types)),,\
     $(error $(sm.this.type) is not valid module type(see: $(sm.global.module_types))))\
 $(if $(sm.this.args.toolset),\
   $(if $(call equal,$(sm.this.type),depends),\
       ,$(if $(wildcard $(sm.dir.buildsys)/tools/$(sm.this.args.toolset).mk),\
            ,$(error smart: toolset $(sm.this.args.toolset) not unknown)))\
   $(eval \
     ifeq ($(origin toolset),command line)
       sm.this.toolset := $(or $(toolset),$(sm.this.args.toolset))
     else
       sm.this.toolset := $(sm.this.args.toolset)
     endif
     ifeq ($$(sm.this.toolset),common)
       #$$(warning TODO: common toolset...)
     else
       ifeq ($$(sm.tool.$$(sm.this.toolset)),)
         include $(sm.dir.buildsys)/loadtool.mk
       endif
       ifeq ($$(sm.tool.$$(sm.this.toolset)),)
         $$(error smart: sm.tool.$$(sm.this.toolset) is not defined)
       endif
       ifeq ($$(sm.this.suffix),)
         $$(call sm-check-defined,sm.tool.$$(sm.this.toolset).target.suffix.$(sm.os.name).$(sm.this.type))
         sm.this.suffix := $$(sm.tool.$$(sm.this.toolset).target.suffix.$(sm.os.name).$(sm.this.type))
       endif
     endif
    ))\
 $(if $(filter $(sm.this.type),depends docs),\
     ,$(if $(sm.this.toolset),,$(error smart: toolset is not set)))
endef

## Load the build script for the specified module.
## NOTE: The build script should definitely defined a module using sm-new-module.
define sm-load-module
$(eval \
   sm.this.args.smartfile := $(strip $1)
 )\
$(info smart: load '$(sm.this.args.smartfile)'..)\
$(eval \
  ######
  ifeq ($(sm.this.args.smartfile),)
    $$(error must specify the smart.mk file for the module)
  endif
  ######
  ifeq ($(wildcard $(sm.this.args.smartfile)),)
    $$(error module build script '$(sm.this.args.smartfile)' missed)
  endif
  ######
  ##########
  include $(sm.dir.buildsys)/preload.mk
  include $(sm.this.args.smartfile)
  -include $(sm.dir.buildsys)/postload.mk
 )
endef #sm-load-module

##
define sm-use-module
 $(eval \
   sm.this.args.name := $(strip $1)
  )\
 $(warning TODO: load and use module $(sm.this.args.name) from sm.global.module_path)
endef #sm-use-module

##
define sm-import-module
 $(eval \
   sm.this.args.name := $(strip $1)
  )\
 $(warning TODO: load and use module $(sm.this.args.name) from sm.global.module_path)
endef #sm-import-module

## Find level-one sub-modules.
define sm-find-sub-modules
$(wildcard $(strip $1)/*/smart.mk)
endef

define sm-compute-compile-id
$(eval \
  ifeq ($(sm.var.__module.compile_count),)
    sm.var.__module.compile_count := $(strip $1)
  else
    sm.var.__module.compile_count := \
      $(shell expr $(sm.var.__module.compile_count) + $(strip $1))
  endif
 )$(sm.var.__module.compile_count)
endef #sm-compute-compile-id

## Generate compilation rules for sources
sm-generate-objects = $(call sm-deprecated, sm-generate-objects, sm-compile-sources)
define sm-compile-sources
 $(if $(strip $(sm.this.sources) $(sm.this.sources.external)),\
    $(eval _sm_log = $$(if $(sm.log.filename),echo $$1 >> $(sm.out)/$(sm.log.filename),true))\
    $(info smart: objects for '$(sm.this.name)' by $(strip $(sm-this-makefile)))\
    $(eval sm.var.__module.objects_only := true
           sm.var.__module.compile_id := $(call sm-compute-compile-id,1)
           include $(sm.dir.buildsys)/build-rules.mk
           sm.var.__module.objects_only :=)\
   ,$(error smart: No sources defined))
endef

## sm-generate-implib - Generate import library for shared objects.
define sm.code.generate-implib-win32
  sm.this.depends += $(sm.out.lib)
  sm.this.targets += $(sm.out.lib)/lib$(sm.this.name).a
  sm.this.link.flags += -Wl,-out-implib,$(sm.out.lib)/lib$(sm.this.name).a
 $(sm.out.lib)/lib$(sm.this.name).a:$$(sm.var.$(sm.this.name).module_targets)
endef #sm.code.generate-implib-win32
define sm.code.generate-implib-linux
  sm.this.targets += $(sm.out.lib)/lib$(sm.this.name).so
 $(sm.out.lib)/lib$(sm.this.name).so:$(sm.out.lib) $$(sm.var.$(sm.this.name).module_targets)
	$$(call sm.tool.common.ln,$(sm.top)/$$(sm.var.$(sm.this.name).module_targets),$$@)
endef #sm.code.generate-implib-linux
define sm-generate-implib
$(call sm-check-not-empty,sm.os.name)\
$(if $(call equal,$(sm.this.type),shared),\
  $(eval $(sm.code.generate-implib-$(sm.os.name))))
endef #sm-generate-implib

## sm-copy-files -- make rules for copying files
define sm-copy-files
$(eval \
  sm.this.args.files := $(strip $1)
  sm.this.args.location := $(strip $2)
 )\
$(eval \
  ######
  ifeq ($(sm.this.args.files),)
    $$(error smart: files must be specified to be copied)
  endif
  ######
  ifeq ($(sm.this.args.location),)
    $$(error smart: target location(directory) must be specified)
  endif
  ##########
  sm.var.__copyfiles := $(sm.this.args.files)
  sm.var.__copyfiles.to := $(sm.this.args.location)
  include $(sm.dir.buildsys)/copyfiles.mk
  sm.var.__copyfiles :=
  sm.var.__copyfiles.to :=
 )
endef

## sm-copy-headers - copy headers into $(sm.out.inc)
## It's a shortcut for: $(call sm-copy-files, $1, $(sm.out.inc)/$2)
define sm-copy-headers
 $(call sm-check-not-empty, sm.out.inc)\
 $(call sm-copy-files,$1,$(sm.out.inc)/$(strip $2))
endef

## sm-build-this - Build the current module
define sm-build-this
$(eval \
  ifeq ($(sm.this.name),)
    $$(error sm.this.name is empty)
  endif
  ######
  ifneq ($(sm.this.type),depends)
    ifeq ($(sm.this.toolset),)
      $$(error sm.this.toolset is empty)
    endif
    ifeq ($(strip $(sm.this.sources)$(sm.this.sources.external)$(sm.this.objects)),)
      $$(error no source or objects defined for '$(sm.this.name)')
    endif
  endif
  ######
  ifneq ($(filter $(strip $(sm.this.type)),t tests),)
    ifeq ($(sm.this.lang),)
      $$(error sm.this.lang must be defined for tests module)
    endif
  endif
  ##########
  sm.global.goals += goal-$(sm.this.name)
  sm.var.__module.compile_id := 0
  include $(sm.dir.buildsys)/build-this.mk
 )\
$(eval \
  ifneq ($(strip $(sm.this.sources.unknown)),)
    $$(error smart: strange sources: $(strip $(sm.this.sources.unknown)))
  endif
 )
endef #sm-build-this

## sm-build-depends  - Makefile code for sm-build-depends
## args: 1: module name (required, for sm-new-module)
##	 2: module depends (required)
##	 3: makefile name for build depends (required, for make command)
##	 4: extra depends (optional, depends of depends)
##	 5: extra make targets (optional, for make command)
##	 6: make command name (optional, e.g: gmake, default to 'make')
##	 7: log type (optional, default: 'smart')
define sm-build-depends.code
 $(if $1,,$(error module name is empty (arg 1)))\
 $(if $2,,$(error module depends is empty (arg 2)))\
 $(if $3,,$(error module makefile-name is empty (arg 3)))\

 $$(call sm-new-module, $(strip $1), depends)

 $$(info $(or $(strip $7),smart): $(or $(strip $6),make): $$(sm.this.dir)/$(strip $3))

 sm.this.depends := $$(sm.this.dir)/$(strip $2)
 $$(sm.this.dir)/$(strip $2): $$(sm.this.dir) \
    $$(sm.this.dir)/$(strip $3) \
    $$(foreach s,$4,$$(sm.this.dir)/$$s)
	@rm -vf $$@
	cd $$< && $(or $(strip $6),make) -f $(strip $3) $(strip $5) && touch $$@
 clean-$(strip $1): $$(sm.this.dir)
	cd $$< && $(or $(strip $6),make) -f $(strip $3) clean

 $$(call sm-build-this)
endef #sm-build-depends.code

## Build some dependencies by invoking a external Makefile
## usage: $(call sm-build-depends, name, depends, makefile-name, [extra-depends], [extra-targets], [make-name], [log-type])
define sm-build-depends
$(eval $(sm-build-depends.code))
endef #sm-build-depends


sm-load-sub-modules = $(call sm-deprecated, sm-load-sub-modules, sm-load-subdirs)

## Load all smart.mk in sub directories.
## This will clear variables sm.this.dir and sm.this.dirs
## usage: $(call sm-load-subdirs)
##        $(call sm-load-subdirs, apps tests)
define sm-load-subdirs
$(if $(sm.this.dir),,$(eval sm.this.dir := $(sm-this-dir)))\
$(if $1,$(eval sm.this.dirs += $1))\
$(eval include $(sm.dir.buildsys)/subdirs.mk)
endef

## Command for making out dir
#$(if $(wildcard $1),,$(info mkdir: $1)$(shell [[ -d $1 ]] || mkdir -p $1))
define sm-util-mkdir
$(if $(wildcard $1),,$(shell [[ -d $1 ]] || mkdir -p $1))
endef

## Convert path to relative path (to $(sm.top)).
define sm-relative-path
$(patsubst $(sm.top)/%,%,$(strip $1))
endef

sm-to-relative-path = $(error sm-to-relative-path is deprecated, use sm-relative-path)


################
# Check helpers
################
check-exists = $(call sm-deprecated, check-exists, sm-check-target-exists)
sm-check-exists = $(call sm-deprecated, sm-check-exists, sm-check-target-exists)
define sm-check-target-exists
$(if $(wildcard $(strip $1)),,$(error $(or $(strip $2),target '$(strip $1)' is not ready)))
endef #sm-check-target-exists

define sm-check-directory
$(if $(shell [[ -d $1 ]] && echo true),,\
  $(error $(or $(strip $2),directory '$(strip 1)' is not ready)))
endef #sm-check-directory

define sm-check-file
$(if $(shell [[ -d $1 ]] && echo true),,\
  $(error $(or $(strip $2),file '$(strip 1)' is not ready)))
endef #sm-check-file

## Ensure not empty of var, eg. $(call sm-check-not-empty, sm.top)
define sm-check-not-empty
$(if $(strip $1),,$(error sm-check-not-empty accept a var-name))\
$(if $($(strip $1)),,$(error $(or $(strip $2),$(strip $1) is empty)))
endef #sm-check-not-empty

## Ensure empty of var, eg. $(call sm-check-empty, sm.var.blah)
define sm-check-empty
$(if $(strip $1),,$(error sm-check-not-empty accept a var-name))\
$(if $($(strip $1)),$(error $(or $(strip $2),$(strip $1) is not empty)))
endef #sm-check-empty

## eg. $(call sm-check-value, sm.top, foo/bar)
define sm-check-value
$(if $(call equal,$(origin $(strip $1)),undefined),\
  $(error $(or $(strip $3),smart: '$(strip $1)' is undefined)))\
$(if $(call equal,$($(strip $1)),$(strip $2)),,\
  $(error $(or $(strip $3),smart: $$($(strip $1)) != '$(strip $2)', but '$($(strip $1))')))
endef #sm-check-value

## Equals of two vars, eg. $(call sm-check-equal, foo, foo)
define sm-check-equal
$(if $(call equal,$(strip $1),$(strip $2)),,\
  $(error $(or $(strip $3),smart: '$(strip $1)' != '$(strip $2)')))
endef #sm-check-equal

## Not-Equals of two vars, eg. $(call sm-check-not-equal, foo, foo)
define sm-check-not-equal
$(if $(call equal,$(strip $1),$(strip $2)),\
  $(error $(or $(strip $3),smart: '$(strip $1)' == '$(strip $2)')))
endef #sm-check-not-equal

## eg. $(call sm-check-origin, sm.top, file)
define sm-check-origin
$(if $(call equal,$(origin $(strip $1)),$(strip $2)),,\
  $(error $(or $(strip $3),smart: '$(strip $1)' is not '$(strip $2)', but of '$(origin $(strip $1))')))
endef #sm-check-origin

## eg. $(call sm-check-defined, sm.top)
define sm-check-defined
$(if $(call equal,$(origin $(strip $1)),undefined),\
  $(error $(or $(strip $2),smart: '$(strip $1)' is undefined)))
endef #sm-check-defined

## eg. $(call sm-check-undefined, sm.top)
define sm-check-undefined
$(if $(call equal,$(origin $(strip $1)),undefined),,\
  $(error $(or $(strip $2),smart: '$(strip $1)' must no be defined)))
endef #sm-check-defined

## Check the flavor of a var (undefined, recursive, simple)
## eg. $(call sm-check-flavor, sm.top, simple, Bad sm.top var)
define sm-check-flavor
$(if $(call equal,$(flavor $(strip $1)),$(strip $2)),,\
  $(error $(or $(strip $3),smart: '$(strip $1)' is not '$(strip $2)', but '$(flavor $(strip $1))')))
endef #sm-check-flavor

## eg. $(call sm-check-in-list,item,list-name)
define sm-check-in-list
$(if $(strip $1),\
    $(if $(strip $2),\
        $(if $(filter $1,$($(strip $2))),,\
          $(error $(or $(strip $3),smart: '$(strip $1)' not in '$(strip $2)'))),\
      $(error $(or $(strip $3),smart: list name is empty))),\
  $(error $(or $(strip $3),smart: item is empty)))
endef #sm-check-in-list
