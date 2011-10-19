# -*- mode: Makefile:gnu -*-
#	Copyright(c) 2009, by Zhan Xin-ming, duzy@duzy.info
#

# TODO: smart conditional
# $(cond
#   (foo $(var-1))
#   (bar $(var-2))
#   (car $(var-3)))

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
endef #sm-deprecated

define sm-this-makefile
$(lastword $(MAKEFILE_LIST))
endef #sm-this-makefile

define sm-this-dir
$(patsubst %/,%,$(dir $(lastword $(MAKEFILE_LIST))))
endef #sm-this-dir

define sm-module-dir
$(if $(sm.this.name),$(call sm-this-dir),\
  $(error 'sm.this.name' is empty, please use 'sm-this-dir' instead))
endef #sm-module-dir

define sm-module-type-name
$(if $(call equal,$1,dynamic),shared,\
    $(if $(call equal,$1,executable),exe,\
        $(if $(call equal,$1,tests),t,$1)))
endef #sm-module-type-name

##
define sm-reset-module
$(eval \
  sm.temp._mod := $(strip $1)
 )$(foreach sm.temp._, $(sm.module.properties),\
    $(eval $(sm.temp._mod)$(sm.temp._) :=))
endef #sm-reset-module

##
define sm-clone-module
$(eval \
  sm.temp._src := $(strip $1)
  sm.temp._dst := $(strip $2)
 )\
$(foreach sm.temp._,\
     $(sm.module.properties)\
     $(foreach _,$($(sm.temp._src).headers.*), .headers.$_! .headers.$_),\
  $(eval sm.temp._flavor := $(flavor $(sm.temp._src)$(sm.temp._)))\
  $(eval \
    ifeq ($(sm.temp._flavor),simple)
      $(sm.temp._dst)$(sm.temp._) := $($(sm.temp._src)$(sm.temp._))
    else
    ifeq ($(sm.temp._flavor),recursive)
      $(sm.temp._dst)$(sm.temp._) = $(value $(sm.temp._src)$(sm.temp._))
    else
      #(undefine $(sm.temp._dst)$(sm.temp._))
    endif
    endif
   ))
endef #sm-clone-module

# sm-new-module must be used before any 'include' commands, since
# it invokes sm-module-dir and sm-this-makefile
sm-new-module = $(sm-new-module-internal)
define sm-new-module-internal
 $(eval \
   sm.temp._name := $(strip $1)
   sm.temp._type := $(strip $2)
   sm.temp._toolset := $(strip $3)

   ifeq ($$(sm.temp._name),)
     $$(error module name(as arg 1) required)
   endif

   ifneq ($$(filter $$(sm.temp._name),$(sm.global.modules)),)
     $$(error module "$$(sm.temp._name)" already defined in "$$(sm.global.modules.$$(sm.temp._name))")
   endif

   ifeq ($(origin toolset),command line)
     sm.temp._toolset := $(toolset)
   endif

   sm.temp._type := $$(call sm-module-type-name,$$(sm.temp._type))
   sm.temp._suffix := $$(suffix $$(sm.temp._name))
   sm.temp._name := $$(basename $$(sm.temp._name))

   ifeq ($$(sm.temp._name),)
     $$(error smart: module name is empty)
   endif
  )\
 $(eval \
   sm.this.type := $(sm.temp._type)
   sm.this.name := $(sm.temp._name)
   sm.this.suffix := $(sm.temp._suffix)
   sm.this.dir := $$(call sm-module-dir)
   sm.this.dirs :=
   sm.this.makefile := $$(call sm-this-makefile)
   sm.this.gen_deps := true

   sm.global.modules += $(sm.temp._name)
   sm.global.modules.$(sm.temp._name) := $$(sm.this.makefile)

   ifeq ($$(sm.this.type),shared)
     sm.this.out_implib := $$(sm.this.name)
   endif
   ifeq ($$(sm.this.type),docs)
     sm.temp._toolset := common
   endif
   sm.this.docs.format := .pdf

   ifeq ($$(filter $$(sm.this.type),$(sm.global.module_types)),)
     $$(error smart "$$(sm.this.type)" is not valid module type(see: $(sm.global.module_types)))
   endif
  )\
 $(if $(sm.temp._toolset),$(eval \
   ifeq ($(sm.this.type),depends)
     ifeq ($(wildcard $(sm.dir.buildsys)/tools/$(sm.temp._toolset).mk),)
       $$(error smart: toolset $(sm.temp._toolset) not unknown)
     endif
   endif
   ######
   sm.this.toolset := $(sm.temp._toolset)
   ######
   ifeq ($$(sm.this.toolset),common)
     #$$(warning TODO: common toolset...)
   else
     ifeq ($$(sm.tool.$$(sm.this.toolset)),)
       include $(sm.dir.buildsys)/loadtool.mk
     endif
     ######
     ifeq ($$(sm.tool.$$(sm.this.toolset)),)
       $$(error smart: sm.tool.$$(sm.this.toolset) is not defined)
     endif
     ######
     ifeq ($$(sm.this.suffix),)
       $$(call sm-check-defined,sm.tool.$$(sm.this.toolset).target.suffix.$(sm.os.name).$(sm.this.type))
       sm.this.suffix := $$(sm.tool.$$(sm.this.toolset).target.suffix.$(sm.os.name).$(sm.this.type))
     endif
   endif
  ))\
 $(eval \
   ifeq ($(filter $(sm.this.type),none depends docs),)
     $(if $(sm.this.toolset),,$$(error smart: toolset is not set))
   endif
  )
endef #sm-new-module-internal
#####
define sm-new-module-external
$(sm-new-module-internal)\
$(info smart: external module "$(sm.this.name)" of type "$(sm.this.type)")\
$(eval \
  sm.this.is_external := true
  sm.this.type := $$(sm.this.type)+external
  $$(call sm-clone-module, sm.this, sm.module.$(sm.this.name))
 )
endef #sm-new-module-external

## Load the build script for the specified module, and returns the module name
## via sm.result.module_name variable .
## NOTE: The build script should definitely defined a module using sm-new-module.
define sm-load-module
$(eval \
   sm.temp._smartfile := $(strip $(wildcard $1))
 )\
$(info smart: load '$(sm.temp._smartfile)'..)\
$(eval \
  ######
  ifeq ($(sm.temp._smartfile),)
    $$(error must specify the smart.mk file for the module)
  endif
  ######
  ifeq ($(wildcard $(sm.temp._smartfile)),)
    $$(error module build script '$(sm.temp._smartfile)' missed)
  endif
  ##########
  include $(sm.dir.buildsys)/preload.mk
  include $(sm.temp._smartfile)
  sm.result.module.name := $$(sm.this.name)
  -include $(sm.dir.buildsys)/postload.mk
  ##########
 )
endef #sm-load-module

##
## This is a alternative option for sm.this.using.
##
## The sm.this.using alt is now failed because of this error:
## foobar/bar/smart.mk:13: *** prerequisites cannot be defined in command scripts
##
## Import and smart build script and use it for the current module.
sm-use-module = $(call sm-deprecated, sm-use-module, sm-import)
define sm-import
 $(eval \
   sm.temp._modir := $(strip $1)
   sm.temp._using := $$(wildcard $$(sm.temp._modir)/smart.mk)

   ifeq ($(sm.this.name),)
     $$(error smart: sm.this.name is empty, must use sm-new-module first)
   endif

   sm._this := sm.module.$(sm.this.name)
  )\
 $(eval \
   ifeq ($($(sm._this)._configured),true)
     $$(error smart: $(sm.this.name) already configured, cannot do using)
   endif

   ifeq ($(filter $(sm.this.name),$(sm.global.using)),$(sm.this.name))
     $$(error smart: internal: recursive using: $(sm.this.name): $(sm.global.using))
   endif
   sm.global.using += $(sm.this.name)
  )\
 $(info smart: import "$(sm.temp._modir)" for "$(sm.this.name)"..)\
 $(call sm-clone-module, sm.this, $(sm._this))\
 $(call sm-load-module, $(sm.temp._using))\
 $(eval \
   sm._that := sm.module.$(sm.this.name)

   ## restore context to the previous module
   sm.this.name := $(lastword $(sm.global.using))
  )\
 $(eval \
   ifeq ($(sm.this.name),)
     $$(error smart: internal: sm.global.using damaged: $(sm.global.using))
   else
     #sm.global.using := $$(wordlist 1,$(words $(sm.global.using))-1,$(sm.global.using))
     sm.global.using := $(filter-out $(sm.this.name),$(sm.global.using))
   endif
   sm._this := sm.module.$(sm.this.name)
  )\
 $(eval \
   $(sm._this).using_list += $($(sm._that).name)
  )\
 $(info smart: module "$(sm.result.module.name)" used by "$(sm.this.name)")\
 $(call sm-clone-module, $(sm._this), sm.this)
endef #sm-import

##
## Use a module that it's already loaded.
## 
## same as sm-import, except that sm-use accepts a module name instead of
## a module built script and it can only "use" a loaded module.
define sm-use
 $(eval \
   sm.temp._name := $(strip $1)

   ifeq ($(sm.this.name),)
     $$(error smart: sm.this.name is empty, must call sm-new-module first)
   endif

   ifeq ($$(sm.temp._name),)
     $$(error smart: module name is empty)
   endif

   ifeq ($(sm.this.name),$$(sm.temp._name))
     $$(error smart: module cannot make use of itself)
   endif

   sm._this := sm.module.$(sm.this.name)
   sm._that := sm.module.$$(sm.temp._name)
  )\
 $(eval \
   ifeq ($($(sm._this)._configured),true)
     $$(error smart: $(sm.this.name) already configured, cannot do using)
   endif
  )\
 $(no-info smart: use "$(sm.temp._name)" for "$(sm.this.name)"..)\
 $(eval \
   ifneq ($($(sm._that).name),$(sm.temp._name))
     $$(error smart: module "$(sm.temp._name)" is misconfigured as "$($(sm._that).name)")
   endif

   ifeq ($(filter $(sm.temp._name),$($(sm._this).using_list)),$(sm.temp._name))
     $$(error smart: module "$(sm.temp._name)" already been used)
   endif
   $(sm._this).using_list += $($(sm._that).name)
  )
endef #sm-use

##
## Use a module defined in a external smart script.
##
## This will first execute the external smart script but nothing will be built
## from inside that script, it just extract "export" parameters and "use" it for
## the current module.
define sm-use-external
 $(eval \
   sm.temp._modir := $(strip $1)
   ifeq ($$(sm.temp._modir),)
     $$(error smart: must specify the location of the external module)
   endif

   sm.temp._using := $$(wildcard $$(sm.temp._modir)/smart.mk)
   ifeq ($$(sm.temp._using),)
     $$(error smart: external module "$$(sm.temp._modir)" does not have a smart.mk)
   endif

   ifeq ($(sm.this.name),)
     $$(error smart: sm.this.name is empty, must use sm-new-module first)
   endif

   sm._this := sm.module.$(sm.this.name)
  )\
 $(eval \
   ifeq ($(filter $(sm.this.name),$(sm.global.using)),$(sm.this.name))
     $$(error smart: internal: recursive using: $(sm.this.name)(external): $(sm.global.using))
   endif
   sm.global.using += $(sm.this.name)
  )\
 $(no-info smart: use external "$(sm.temp._modir)" for "$(sm.this.name)"..)\
 $(eval \
   $$(call sm-clone-module, sm.this, $(sm._this))
   sm-new-module = $$(sm-new-module-external)
   sm-compile-sources = $$(sm-compile-sources-external)
   sm-copy-files = $$(sm-copy-files-external)
   sm-build-depends = $$(sm-build-depends-external)
   sm-build-this = $$(sm-build-this-external)

   ## use include here instead of sm-load-module
   include $(sm.dir.buildsys)/preload.mk
   include $(sm.temp._using)
  )\
 $(eval \
   sm._that := sm.module.$(sm.this.name)

   ## restore context to the previous module
   sm.this.name := $(lastword $(sm.global.using))
  )\
 $(eval \
   ifeq ($(sm.this.name),)
     $$(error smart: internal: sm.global.using damaged: $(sm.global.using))
   else
     #sm.global.using := $$(wordlist 1,$(words $(sm.global.using))-1,$(sm.global.using))
     sm.global.using := $(filter-out $(sm.this.name),$(sm.global.using))
   endif

   sm._this := sm.module.$(sm.this.name)

   ifeq ($$(sm._this),$(sm._that))
     $$(error smart: internal: self using: $$(sm._this), $(sm._that))
   endif

   sm-new-module = $$(sm-new-module-internal)
   sm-compile-sources = $$(sm-compile-sources-internal)
   sm-copy-files = $$(sm-copy-files-internal)
   sm-build-depends = $$(sm-build-depends-internal)
   sm-build-this = $$(sm-build-this-internal)
   $$(call sm-clone-module, $$(sm._this), sm.this)
  )\
 $(eval \
   $(sm._this).using_list += $($(sm._that).name)
  )\
 $(info smart: external module "$($(sm._that).name)" used by "$(sm.this.name)")
endef #sm-use-external

## Find level-one sub-modules.
# define sm-find-sub-modules
# $(wildcard $(strip $1)/*/smart.mk)
# endef #sm-find-sub-modules
sm-find-sub-modules = $(error sm-find-sub-modules is deprecated)

##
define sm-compute-compile-num
$(eval \
  ifeq ($(sm._this),)
    $$(error smart: internal: sm._this is empty)
  endif
  ifeq ($($(sm._this)._compile_count),)
    $(sm._this)._compile_count := $(strip $1)
  else
    sm._cc := $(shell expr $($(sm._this)._compile_count) + $(strip $1))
    $(sm._this)._compile_count := $$(sm._cc)
  endif
 )$($(sm._this)._compile_count)
endef #sm-compute-compile-num

## Generate compilation rules for sources
sm-compile-sources = $(sm-compile-sources-internal)
define sm-compile-sources-internal
 $(if $(strip $(sm.this.sources) $(sm.this.sources.external)),\
    $(no-info smart: intermediates for '$(sm.this.name)' by $(strip $(sm-this-makefile)))\
    $(eval \
      ifeq ($(sm.this.name),)
        $$(error smart: internal: sm.this.name is empty)
      endif

      sm._this := sm.module.$(sm.this.name)
     )\
    $(call sm-clone-module, sm.this, $(sm._this))\
    $(eval \
      ifneq ($($(sm._this).type),none)
        $(sm._this)._cnum := $(call sm-compute-compile-num,1)
        $(sm._this)._intermediates_only := true
        include $(sm.dir.buildsys)/build-rules.mk
        $(sm._this)._intermediates_only :=
      endif
     )\
   ,$(error smart: No sources defined))
endef #sm-compile-sources-internal
#####
define sm-compile-sources-external
endef #sm-compile-sources-external

sm-generate-implib = $(sm-generate-implib-internal)
## sm-generate-implib - Generate import library for shared objects.
define sm.code.generate-implib-win32
  sm.this.depends += $(sm.out.lib)
  sm.this.targets += $(sm.out.lib)/lib$(sm.this.name).a
  sm.this.link.flags += -Wl,-out-implib,$(sm.out.lib)/lib$(sm.this.name).a
 $(sm.out.lib)/lib$(sm.this.name).a:$$(sm.module.$(sm.this.name).module_targets)
endef #sm.code.generate-implib-win32
#####
define sm.code.generate-implib-linux
  sm.this.targets += $(sm.out.lib)/lib$(sm.this.name).so
 $(sm.out.lib)/lib$(sm.this.name).so:$(sm.out.lib) $$(sm.module.$(sm.this.name).module_targets)
	$$(call sm.tool.common.ln,$(sm.top)/$$(sm.module.$(sm.this.name).module_targets),$$@)
endef #sm.code.generate-implib-linux
#####
define sm-generate-implib-internal
$(call sm-check-not-empty,sm.os.name)\
$(if $(call equal,$(sm.this.type),shared),\
    $(eval $(sm.code.generate-implib-$(sm.os.name))),\
  $(if $(filter shared%,$(sm.this.type)),,\
      $(error smart: cannot generate import lib for $(sm.this.type) module)))
endef #sm-generate-implib-internal
#####
define sm-generate-implib-external
endef #sm-generate-implib-external

## sm-copy-files -- make rules for copying files
sm-copy-files = $(sm-copy-files-internal)
define sm-copy-files-internal
$(eval \
  sm.temp._files := $(strip $1)
  sm.temp._location := $(strip $2)
 )\
$(eval \
  ######
  ifeq ($(sm.temp._files),)
    $$(error smart: files must be specified to be copied)
  endif
  ######
  ifeq ($(sm.temp._location),)
    $$(error smart: target location(directory) must be specified)
  endif
  ##########
  sm.var.temp._d := $(sm.temp._location:$(sm.top)/%=%)
 )\
$(foreach v, $(sm.temp._files),\
   $(eval \
     sm.this.depends.copyfiles += $(sm.var.temp._d)/$(notdir $v)
     $(sm.var.temp._d)/$(notdir $v): $(sm.this.dir:$(sm.top)/%=%)/$v ;\
       @( echo smart: copy: $$@ ) &&\
       ([ -d $$(dir $$@) ] || mkdir -p $$(dir $$@)) &&\
       ($(sm.tool.common.CP) -u $$< $$@)
    ))
endef #sm-copy-files-internal
#####
define sm-copy-files-external
endef #sm-copy-files-external

## sm-copy-headers - copy headers into $(sm.out.inc)
## It's a shortcut for: $(call sm-copy-files, $1, $(sm.out.inc)/$2)
# define sm-copy-headers
#  $(call sm-check-not-empty, sm.out.inc)\
#  $(call sm-copy-files,$1,$(sm.out.inc)/$(strip $2))
# endef #sm-copy-headers
sm-copy-headers = $(error "sm-copy-headers" is deprecated, use "sm.this.headers" and "sm.this.headers.*" instead)

## sm-build-this - Build the current module
sm-build-this = $(sm-build-this-internal)
define sm-build-this-internal
$(eval \
  ifeq ($(sm.this.name),)
    $$(error sm.this.name is empty)
  endif
  ######
  ifeq ($(filter $(strip $(sm.this.type)),depends none),)
    ifeq ($(sm.this.toolset),)
      $$(error sm.this.toolset is empty)
    endif
    ifeq (${strip \
             $(sm.this.sources)\
             $(sm.this.sources.external)\
             $(sm.this.intermediates)},)
      $$(error no source or intermediates defined for '$(sm.this.name)')
    endif
  else
    ifeq ($(strip $(sm.this.type)),depends)
      ifeq (${strip $(sm.this.depends)},)
        $$(error no dependencies defined for '$(sm.this.name)')
      endif
    endif
  endif
  ######
  ifneq ($(filter $(strip $(sm.this.type)),t tests),)
    ifeq ($(sm.this.lang),)
      $$(error sm.this.lang must be defined for tests module)
    endif
  endif
  ######
  ifneq ($(sm.this.archive.flags),)
    $$(error sm.this.archive.* is deprecated, using sm.this.link.* instead)
  endif
  ifneq ($(sm.this.archive.flags.infile),)
    $$(error sm.this.archive.* is deprecated, using sm.this.link.* instead)
  endif
  ifneq ($(sm.this.archive.libs),)
    $$(error sm.this.archive.* is deprecated, using sm.this.link.* instead)
  endif
  ##########
  sm._this := sm.module.$(sm.this.name)
  $$(call sm-clone-module, sm.this, $$(sm._this))
  ifneq ($$($$(sm._this).type),none)
    ifeq ($$($$(sm._this)._already_built),true)
      $$(error module "$(sm.this.name)" has been built already)
    endif

    $$(sm._this)._cnum := 0
    include $(sm.dir.buildsys)/build-this.mk
    $$(sm._this)._already_built := true
  endif
 )\
$(eval \
  ifneq ($(strip $($(sm._this).sources.unknown)),)
    $$(error smart: strange sources: $(strip $($(sm._this).sources.unknown)))
  endif
 )
endef #sm-build-this-internal
#####
define sm-build-this-external
$(eval \
  sm._this := sm.module.$(sm.this.name)
 )\
$(call sm-clone-module, sm.this, $(sm._this))
endef #sm-build-this-external

## sm-build-depends  - Makefile code for sm-build-depends
## args: 1: module name (required, for sm-new-module)
##	 2: module depends (required)
##	 3: makefile name for build depends (required, for make command)
##	 4: extra depends (optional, depends of depends)
##	 5: extra make targets (optional, for make command)
##	 6: make command name (optional, e.g: gmake, default to 'make')
##	 7: log type (optional, default: 'smart')
## Build some dependencies by invoking a external Makefile
## usage: $(call sm-build-depends, name, depends, makefile-name, [extra-depends], [extra-targets], [make-name], [log-type])
sm-build-depends = $(sm-build-depends-internal)
define sm-build-depends-internal
$(eval \
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
 )
endef #sm-build-depends-internal
#####
define sm-build-depends-external
endef #sm-build-depends-external


sm-load-sub-modules = $(call sm-deprecated, sm-load-sub-modules, sm-load-subdirs)

## Load all smart.mk in sub directories.
## This will clear variables sm.this.dir and sm.this.dirs
## usage: $(call sm-load-subdirs)
##        $(call sm-load-subdirs, apps tests)
define sm-load-subdirs
$(if $(sm.this.dir),,$(eval sm.this.dir := $(sm-this-dir)))\
$(if $1,$(eval sm.this.dirs += $(strip $1)))\
$(eval \
  ifeq ($(wildcard $(sm.this.dir)),)
    $$(error smart: sm.this.dir must be specified first)
  endif

  ifneq ($(strip $(sm.this.dirs)),)
    sm.temp._submods := $(foreach _,$(sm.this.dirs),$(wildcard $(sm.this.dir)/$_/smart.mk))
  else
    sm.temp._submods := $(wildcard $(sm.this.dir)/*/smart.mk)
  endif
  ## must clear sm.this.dirs in case of consequence sm-load-subdirs
  ## from in a subdir
  sm.this.dirs :=
 )\
$(foreach _, $(sm.temp._submods), $(call sm-load-module, $_))
endef #sm-load-subdirs

## Command for making out dir
#$(if $(wildcard $1),,$(info mkdir: $1)$(shell [[ -d $1 ]] || mkdir -p $1))
define sm-util-mkdir
$(if $(wildcard $1),,$(shell [[ -d $1 ]] || mkdir -p $1))
endef #sm-util-mkdir

## Convert path to relative path (to $(sm.top)).
# define sm-relative-path
# $(patsubst $(sm.top)/%,%,$(strip $1))
# endef #sm-relative-path
sm-relative-path = $(error sm-relative-path is deprecated, use $$(var:$$(sm.top)/%=%))
sm-to-relative-path = $(error sm-to-relative-path is deprecated, use sm-relative-path)

## Do a interpolation on a input file according to a set of variables
define sm-interpolate
$(eval \
  sm.temp._vars := $(strip $1)
  sm.temp._output := $(strip $2)
  sm.temp._input := $(strip $3)
  ifeq ($$(sm.temp._input),)
    sm.temp._input := $$(sm.temp._output).in
  endif
  ifeq ($$(wildcard $$(sm.temp._input)),)
    $$(error smart: $$(sm.temp._input) not found)
  endif
  ifeq ($$(sm.temp._vars),)
    $$(error variable set name is empty)
  endif
 )\
$(eval $(subst ;,,$($(sm.temp._vars))))\
$(eval sm.temp._vars := $(subst $(newline),,$(subst $(linefeed),,$($(sm.temp._vars)))))\
$(eval sm.temp._vars := $(subst ",\",$(sm.temp._vars))
  #"
 )\
$(eval \
  $(sm.temp._output) : $(sm.dir.buildsys)/scripts/interpolate.awk $(sm.temp._input)
	awk -f $$< -- -vars "$(sm.temp._vars)" $(sm.temp._input) > $$@
 )
endef #sm-interpolate


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
