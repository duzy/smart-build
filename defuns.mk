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
$(if $(call is-true),,true)
endef

#####
# Toolset support
#####

sm.var.rule-action.static := archive
sm.var.rule-action.shared := link
sm.var.rule-action.exe := link

#
#  eg. $(call sm-register-sources, c++, gcc, .cpp .c++ .cc .CC .C)
#  eg. $(call sm-register-sources, asm, gcc, .s .S)
# TODO: make this job automaticly according sm.this.toolset
define sm-register-sources
 $(if $1,,$(error smart: must provide lang-type as arg 1))\
 $(if $2,$(call sm-check-not-equal,$(strip $2),common,smart: cannot register toolset of name 'common'),\
   $(error smart: must provide toolset as arg 2))\
 $(if $3,,$(error smart: must provide source extensions as arg 3))\
 $(eval sm._toolset.mk := $(sm.dir.buildsys)/tools/$(strip $2).mk)\
 $(if $(wildcard $(sm._toolset.mk)),,$(error smart: Toolset '$(strip $2)' unsupported.))\
 $(if $(sm.tool.$(strip $2)),,\
   $(eval include $(sm._toolset.mk))\
   $(if $(sm.tool.$(strip $2)),$(info smart: '$(strip $2)' toolset included),\
      $(error toolset '$(strip $2)' not well defined in '$(sm._toolset.mk)'))\
   $(foreach sm._var._temp._lang,$(sm.tool.$(strip $2).langs),\
        $(call sm-check-undefined,sm.rule.compile.$(strip $1),    smart: '$(sm.toolset.for.$(sm._var._temp._lang))' has been registered for '$(strip $1)')\
        $(call sm-check-undefined,sm.rule.dependency.$(strip $1), smart: '$(sm.toolset.for.$(sm._var._temp._lang))' has been registered for '$(strip $1)')\
        $(call sm-check-undefined,sm.rule.archive.$(strip $1),    smart: '$(sm.toolset.for.$(sm._var._temp._lang))' has been registered for '$(strip $1)')\
        $(call sm-check-undefined,sm.rule.link.$(strip $1),       smart: '$(sm.toolset.for.$(sm._var._temp._lang))' has been registered for '$(strip $1)')))\
 $(if $(sm.tool.$(strip $2)),,$(error smart: Toolset '$(strip $2)' unimplemented))\
 $(call sm-check-in-list,$(strip $1),sm.tool.$(strip $2).langs,smart: toolset '$(strip $2)' donnot support '$(strip $1)')\
 $(call sm-check-origin,sm.tool.$(strip $2),file,smart: toolset '$(strip $2)' unimplemented)\
 $(foreach sm._var._temp._lang,$(sm.tool.$(strip $2).langs),\
     $(eval sm.rule.compile.$(sm._var._temp._lang) = $$(call sm.rule.compile,$(sm._var._temp._lang),$$(strip $$1),$$(strip $$2),$$(strip $$3)))\
     $(eval sm.rule.dependency.$(sm._var._temp._lang) = $$(call sm.rule.dependency,$(sm._var._temp._lang),$$(strip $$1),$$(strip $$2),$$(strip $$3),$$(strip $$4)))\
     $(eval sm.rule.archive.$(sm._var._temp._lang) = $$(call sm.rule.archive,$(sm._var._temp._lang),$$(strip $$1),$$(strip $$2),$$(strip $$3),$$(strip $$4)))\
     $(eval sm.rule.link.$(sm._var._temp._lang) = $$(call sm.rule.link,$(sm._var._temp._lang),$$(strip $$1),$$(strip $$2),$$(strip $$3),$$(strip $$4),$$(strip $$5))))\
 $(eval sm.tool.$(strip $2).$(strip $1).suffix += $(strip $3))\
 $(eval sm.toolset.for.$(strip $1) := $(strip $2))\
 $(foreach s,$3,$(eval sm.toolset.for.file$s := $(strip $2)))
endef #sm-register-sources

#####
# 
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

sm.var.target_suffix_for_win32_static := .a
sm.var.target_suffix_for_win32_shared := .so
sm.var.target_suffix_for_win32_exe := .exe
sm.var.target_suffix_for_win32_t := .test.exe
sm.var.target_suffix_for_linux_static := .a
sm.var.target_suffix_for_linux_shared := .so
sm.var.target_suffix_for_linux_exe :=
sm.var.target_suffix_for_linux_t := .test

# $(findstring $1,$(sm.global.modules))
define sm-new-module
$(if $1,$(if $(filter $1,$(sm.global.modules)),\
             $(error Module of name '$1' already exists))\
  $(eval sm.this.name := $(basename $(strip $1))
         $$(if $$(sm.this.name),,$$(error The module name is empty))
         sm.this.suffix := $(suffix $(strip $1))
         sm.this.dir := $$(call sm-module-dir)
         sm.this.gen_deps := true
         sm.this.makefile := $$(call sm-this-makefile)
         sm.global.modules += $(strip $1)
         sm.global.modules.$(strip $1) := $$(sm.this.makefile))\
  ,$(error Invalid usage of 'sm-new-module', module name required))\
$(if $2,$(eval \
  sm.this.type := $(call sm-module-type-name,$(strip $2))
  $$(call sm-check-in-list,$$(sm.this.type),sm.global.module_types,only supports module of type '$(sm.global.module_types)')
  ifeq ($$(sm.this.suffix),)
    $$(call sm-check-defined,sm.var.target_suffix_for_$(sm.os.name)_$$(sm.this.type))
    sm.this.suffix := $$(sm.var.target_suffix_for_$(sm.os.name)_$$(sm.this.type))
  endif
  ifeq ($$(sm.this.type),shared)
    sm.this.out_implib := $(sm.this.name)
  endif
  ),)
endef

## Load the build script for the specified module.
define sm-load-module
$(if $1,\
  $(if $(wildcard $1),,$(error module build script '$1' missed!))\
  $(eval $$(info smart: load '$1'..)
    include $(sm.dir.buildsys)/preload.mk
    include $1
    -include $(sm.dir.buildsys)/postload.mk
    ),\
  $(error "Must specify the smart.mk file for the module."))
endef

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
           include $(sm.dir.buildsys)/module.mk
           sm.var.__module.objects_only :=)\
   ,$(error smart: No sources defined))
endef
# $(warning TODO: refactor this for multiple-toolset)\
# $(eval include $(sm.dir.buildsys)/old/objrules.mk),\

## Copy headers to $(sm.out.inc)
##	usage 1: $(call sm-copy-files, $(headers))
##	usage 2: $(call sm-copy-files, $(headers), subdir)
define sm-copy-files
 $(if $1,\
    $(eval sm.var.__copyfiles := $(strip $1)
           sm.var.__copyfiles.to := $(strip $2)
           include $(sm.dir.buildsys)/copyfiles.mk
           sm.var.__copyfiles :=
           sm.var.__copyfiles.to :=
	),\
    $(error smart: You must specify files for arg one))
endef

## Copy headers
define sm-copy-headers
 $(call sm-check-not-empty, sm.out.inc)\
 $(call sm-copy-files,$1,$(sm.out.inc)/$(strip $2))
endef

## Build the current module
define sm-build-this
 $(if $(sm.this.sources)$(sm.this.sources.external)$(sm.this.objects),,\
   $(error no source or objects defined for '$(sm.this.name)'))\
 $(if $(sm.this.name),,$(error sm.this.name must be specified))\
 $(eval sm.global.goals += goal-$(sm.this.name)
        sm.var.__module.compile_id := 0
        include $(sm.dir.buildsys)/buildmod.mk)
endef #sm-build-this

## Load all smart.mk in sub directories.
define sm-load-sub-modules
$(error use sm-load-subdirs instead)
endef

define sm-load-subdirs
$(eval include $(sm.dir.buildsys)/subdirs.mk)
endef

# DEPRECATED
## Define variable prefixed by 'sm.var.temp.'.
## NOTE: Donot use it in multi-level 'include's
##   usage 1: $(call sm-var-temp, :=, value list)
##          : $(call sm-var-temp, ?=, value list)
define sm-var-temp
 $(if $(strip $1),$(if $(filter $(strip $2),= := ?=),\
        $(eval sm.var.temp.$(strip $1)$(strip $2)$(strip $3)
           sm.var.temp.*:=$(strip $1) $(sm.var.temp.*)),
       $(warning Invalid usage of fun 'sm-var-temp'.)),\
   $(warning Defining local variable must provide a name.))
endef

# DEPRECATED
## Unset variables prefixed by 'sm.var.temp.'
define sm-var-temp-clean
 $(foreach v,$(sm.var.temp.*),$(eval sm.var.temp.$v:=))\
 $(eval sm.var.temp.*:=)
endef

## Command for making out dir
#$(if $(wildcard $1),,$(info mkdir: $1)$(shell [[ -d $1 ]] || mkdir -p $1))
define sm-util-mkdir
$(if $(wildcard $1),,$(shell [[ -d $1 ]] || mkdir -p $1))
endef

## Convert path to relative path (to $(sm.top)).
define sm-to-relative-path
$(patsubst $(sm.top)/%,%,$(strip $1))
endef


################
# Check helpers
################
check-exists = $(call sm-deprecated, check-exists, sm-check-target-exists)
sm-check-exists = $(call sm-deprecated, sm-check-exists, sm-check-target-exists)
define sm-check-target-exists
$(if $(wildcard $(strip $1)),,$(error $(or $(strip $2),target '$(strip $1)' is not ready)))
endef

define sm-check-directory
$(if $(shell [[ -d $1 ]] && echo true),,\
  $(error $(or $(strip $2),directory '$(strip 1)' is not ready)))
endef

define sm-check-file
$(if $(shell [[ -d $1 ]] && echo true),,\
  $(error $(or $(strip $2),file '$(strip 1)' is not ready)))
endef

## Ensure not empty of var, eg. $(call sm-check-not-empty, sm.top)
define sm-check-not-empty
$(if $(strip $1),,$(error sm-check-not-empty accept a var-name))\
$(if $($(strip $1)),,$(error $(or $(strip $2),$(strip $1) is empty)))
endef

## Ensure empty of var, eg. $(call sm-check-empty, sm.var.blah)
define sm-check-empty
$(if $(strip $1),,$(error sm-check-not-empty accept a var-name))\
$(if $($(strip $1)),$(error $(or $(strip $2),$(strip $1) is not empty)))
endef

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
endef #sm-check-equal

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
