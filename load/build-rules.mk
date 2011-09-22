#
#  For any source list of mixture suffixes, e.g. 'foo.cpp foo.S foo.w',
#  I will first check sm.tool.$(sm.this.toolset) to see if the toolset
#  can process the source files, if not I will check sm.tool.common for
#  the source files, if sm.tool.common can't handle it, I will complain
#  with a error.
#
#  The source files with suffix '.t' are special fot unit test projects.
#  They are special because event if no toolset will handle with them, 
#  wouldn't it be treated as strange. And processing the .t source files
#  requires sm.this.lang to be specified.
#  

$(call sm-check-not-empty,sm.top)
$(call sm-check-not-empty,sm.this.dir)
$(call sm-check-not-empty,sm.this.name)
$(call sm-check-not-empty,sm.this.type)
$(call sm-check-not-empty,sm.this.toolset,smart: 'sm.this.toolset' for $(sm.this.name) unknown)

sm.var.toolset := sm.tool.$(sm.this.toolset)

ifeq ($($(sm.var.toolset)),)
  include $(sm.dir.buildsys)/loadtool.mk
endif

ifeq ($($(sm.var.toolset)),)
  $(error smart: $(sm.var.toolset) is not defined)
endif

ifeq ($(sm.this.suffix),)
  $(call sm-check-defined,$(sm.var.toolset).target.suffix.$(sm.os.name).$(sm.this.type))
  sm.this.suffix := $($(sm.var.toolset).target.suffix.$(sm.os.name).$(sm.this.type))
endif

$(call sm-check-value, $(sm.var.toolset), true, smart: toolset '$(sm.this.toolset)' is undefined)

ifeq ($(strip $(sm.this.sources)$(sm.this.sources.external)$(sm.this.objects)),)
  $(error smart: no sources or objects for module '$(sm.this.name)')
endif

##################################################

ifeq ($(sm.this.type),t)
 $(if $(sm.this.lang),,$(error smart: 'sm.this.lang' must be defined for tests module))
endif

define sm.code.check-variables
ifneq ($$(sm.global.$1.options),)
  $$(info smart: error in file $(sm.this.makefile))
  $$(error smart: sm.global.$1.options is deprecated, use sm.global.$1.flags)
endif
ifneq ($$(sm.this.$1.options),)
  $$(info smart: error in file $(sm.this.makefile))
  $$(error smart: sm.this.$1.options is deprecated, use sm.this.$1.flags)
endif
ifneq ($$(sm.this.$1.options.infile),)
  $$(info smart: error in file $(sm.this.makefile))
  $$(error smart: sm.this.$1.options.infile is deprecated, use sm.this.$1.flags.infile)
endif
endef #sm.code.check-variables

$(foreach _,compile archive link,$(eval $(call sm.code.check-variables,$_)))

##################################################

sm.var.action.static := archive
sm.var.action.shared := link
sm.var.action.exe := link
sm.var.action.t := link
sm.var.action := $(sm.var.action.$(sm.this.type))
sm.var.depend.suffixes.static := .d
sm.var.depend.suffixes.shared := .d
sm.var.depend.suffixes.exe := .d
sm.var.depend.suffixes.t := .t.d
sm.var.depend.suffixes := $(sm.var.depend.suffixes.$(sm.this.type))
sm.var.this := sm.var.$(sm.this.name)
sm.fun.this := sm.fun.$(sm.this.name)

$(sm.var.this).depend.suffixes := $(sm.var.depend.suffixes)

##########

## Clear compile options for all langs
$(foreach sm.var.temp._lang,$($(sm.var.toolset).langs),\
  $(eval $(sm.var.this).compile.$(sm.var.__module.compile_id).flags.$(sm.var.temp._lang) := )\
  $(eval $(sm.var.this).compile.$(sm.var.__module.compile_id).flags.$(sm.var.temp._lang).computed := ))

## unset sm.var.temp._lang, the name may be used later
sm.var.temp._lang :=

$(sm.var.this).archive.flags :=
$(sm.var.this).archive.flags.computed :=
$(sm.var.this).archive.objects =
$(sm.var.this).archive.objects.computed :=
$(sm.var.this).archive.libs :=
$(sm.var.this).archive.libs.computed :=
$(sm.var.this).link.flags :=
$(sm.var.this).link.flags.computed :=
$(sm.var.this).link.objects =
$(sm.var.this).link.objects.computed :=
$(sm.var.this).link.libs :=
$(sm.var.this).link.libs.computed :=

$(sm.var.this).flag_files :=

## eg. $(call sm.code.add-items,RESULT_VAR_NAME,ITEMS,PREFIX,SUFFIX)
define sm.code.add-items
 $(foreach sm.var.temp._item,$(strip $2),\
     $(eval $(strip $1) += $(strip $3)$(sm.var.temp._item:$(strip $3)%$(strip $4)=%)$(strip $4)))
endef #sm.code.add-items

## eg. $(call sm.code.shift-flags-to-file,compile,options.c++)
define sm.code.shift-flags-to-file-instant
$(if $1,,$(error smart: 'sm.code.shift-flags-to-file' action type in arg 1 is empty))\
$(if $2,,$(error smart: 'sm.code.shift-flags-to-file' needs options type in arg 2))\
$(if $(call is-true,$(sm.this.$1.flags.infile)),\
     $$(call sm-util-mkdir,$(sm.out.tmp)/$(sm.this.name))\
     $$(eval $(sm.var.this).$1.$2 := $$(subst \",\\\",$$($(sm.var.this).$1.$2)))\
     $$(shell echo $$($(sm.var.this).$1.$2) > $(sm.out.tmp)/$(sm.this.name)/$1.$2)\
     $$(eval $(sm.var.this).$1.$2 := @$(sm.out.tmp)/$(sm.this.name)/$1.$2))
endef #sm.code.shift-flags-to-file-instant


define sm.code-shift-flags-to-file-r
  $(sm.var.this).$1.$2.flat := $$(subst \",\\\",$$($(sm.var.this).$1.$2))
  $(sm.var.this).$1.$2 := @$(sm.out.tmp)/$(sm.this.name)/$1.$2
  $(sm.var.this).flag_files += $(sm.out.tmp)/$(sm.this.name)/$1.$2
  $(sm.out.tmp)/$(sm.this.name)/$1.$2: $(sm.this.makefile)
	@$$(info flags: $$@)
	@mkdir -p $(sm.out.tmp)/$(sm.this.name)
	@echo $$($(sm.var.this).$1.$2.flat) > $$@
#  $$(info $(sm.var.this).$1.$2 = $$($(sm.var.this).$1.$2))
#  $$(info $(sm.var.this).$1.$2.flat = $$($(sm.var.this).$1.$2.flat))
endef
## eg. $(call sm.code.shift-flags-to-file,compile,options.c++)
define sm.code.shift-flags-to-file
$(if $1,,$(error smart: 'sm.code.shift-flags-to-file' action type in arg 1 is empty))\
$(if $2,,$(error smart: 'sm.code.shift-flags-to-file' needs options type in arg 2))\
$(if $(call is-true,$(sm.this.$1.flags.infile)),\
   $$(eval $$(call sm.code-shift-flags-to-file-r,$(strip $1),$(strip $2))))
endef #sm.code.shift-flags-to-file

## eg. $(call sm.code.compute-flags-compile,c++)
define sm.code.compute-flags-compile
 $(sm.var.this).compile.$(sm.var.__module.compile_id).flags.$1.computed := true
 $(sm.var.this).compile.$(sm.var.__module.compile_id).flags.$1 :=\
  $(if $(call equal,$(sm.this.type),t),-x$(sm.this.lang))\
  $(strip $($(sm.var.toolset).defines))\
  $(strip $($(sm.var.toolset).defines.$1))\
  $(strip $($(sm.var.toolset).compile.flags))\
  $(strip $($(sm.var.toolset).compile.flags.$1))\
  $(strip $(sm.global.defines))\
  $(strip $(sm.global.defines.$1))\
  $(strip $(sm.global.compile.flags))\
  $(strip $(sm.global.compile.flags.$1))\
  $(strip $(sm.this.defines))\
  $(strip $(sm.this.defines.$1))\
  $(strip $(sm.this.compile.flags))\
  $(strip $(sm.this.compile.flags.$1))
 $$(call sm.code.add-items, $(sm.var.this).compile.$(sm.var.__module.compile_id).flags.$1,\
     $(sm.global.includes) $(sm.this.includes), -I)
 $(call sm.code.shift-flags-to-file,compile,$(sm.var.__module.compile_id).flags.$1)
endef #sm.code.compute-flags-compile

##
define sm.code.compute-flags-link
 $(sm.var.this).link.flags.computed := true
 $(sm.var.this).link.flags :=\
  $(strip $($(sm.var.toolset).link.flags))\
  $(strip $(sm.global.link.flags))\
  $(strip $(sm.this.link.flags))
 $(if $(call equal,$(sm.this.type),shared),\
     $$(if $$(filter -shared,$$($(sm.var.this).link.flags)),,\
        $$(eval $(sm.var.this).link.flags += -shared)))
 $(call sm.code.shift-flags-to-file,link,options)
endef #sm.code.compute-flags-link

define sm.code.compute-flags-archive
 $(sm.var.this).archive.flags.computed := true
 $(sm.var.this).archive.flags := \
  $(strip $(sm.global.archive.flags)) \
  $(strip $(sm.this.archive.flags))
 $(call sm.code.shift-flags-to-file,archive,options)
endef #sm.code.compute-flags-archive

define sm.code.compute-objects-link
 $(sm.var.this).link.objects.computed := true
 $(sm.var.this).link.objects := $($(sm.var.this).objects)
 $(call sm.code.shift-flags-to-file,link,objects)
endef #sm.code.compute-objects-link

define sm.code.compute-objects-archive
 $(sm.var.this).archive.objects.computed := true
 $(sm.var.this).archive.objects := $($(sm.var.this).objects)
 $(call sm.code.shift-flags-to-file,archive,objects)
endef #sm.code.compute-objects-archive

##
define sm.code.compute-libs-link
 $(sm.var.this).link.libs.computed := true
 $(sm.var.this).link.libs :=
 $$(call sm.code.add-items, $(sm.var.this).link.libs,\
     $(sm.global.libdirs) $(sm.this.libdirs), -L)
 $$(call sm.code.add-items, $(sm.var.this).link.libs,\
     $(sm.global.libs) $(sm.this.libs), -l)
 $(call sm.code.shift-flags-to-file,link,libs)
endef #sm.code.compute-libs-link

$(call sm-check-defined,sm.code.compute-flags-compile, smart: 'sm.code.compute-flags-compile' not defined)
$(call sm-check-defined,sm.code.compute-flags-archive, smart: 'sm.code.compute-flags-archive' not defined)
$(call sm-check-defined,sm.code.compute-flags-link,    smart: 'sm.code.compute-flags-link' not defined)
$(call sm-check-defined,sm.code.compute-libs-link,     smart: 'sm.code.compute-libs-link' not defined)

define sm.fun.compute-flags-compile
$(if $($(sm.var.this).compile.$(sm.var.__module.compile_id).flags.$1.computed),,\
   $(eval $(call sm.code.compute-flags-compile,$1)))
endef #sm.fun.compute-flags-compile

define sm.fun.compute-flags-archive
 $(if $($(sm.var.this).archive.flags.computed),,\
   $(eval $(call sm.code.compute-flags-archive)))
endef #sm.fun.compute-flags-archive

define sm.fun.compute-flags-link
 $(if $($(sm.var.this).link.flags.computed),,\
   $(eval $(call sm.code.compute-flags-link)))
endef #sm.fun.compute-flags-link

define sm.fun.compute-objects-archive
 $(if $($(sm.var.this).archive.objects.computed),,\
   $(eval $(call sm.code.compute-objects-archive)))
endef #sm.fun.compute-objects-archive

define sm.fun.compute-libs-archive
 $(eval $(sm.var.this).archive.libs.computed := true)\
 $(eval $(sm.var.this).archive.libs :=)
endef #sm.fun.compute-libs-archive

define sm.fun.compute-objects-link
 $(if $($(sm.var.this).link.objects.computed),,\
   $(eval $(call sm.code.compute-objects-link)))
endef #sm.fun.compute-objects-link

define sm.fun.compute-libs-link
 $(if $($(sm.var.this).link.libs.computed),,\
   $(eval $(call sm.code.compute-libs-link)))
endef #sm.fun.compute-libs-link

##################################################

## The output object file prefix
sm.var.temp._object_prefix := \
  $(call sm-relative-path,$(sm.out.obj))$(sm.this.dir:$(sm.top)%=%)

## Fixes the prefix for 'out/debug/obj.'
sm.var.temp._object_prefix := $(sm.var.temp._object_prefix:%.=%)

# BUG: wrong if more than one sm-build-this occurs in a smart.mk
#$(warning $(sm.this.name): $(sm.var.temp._object_prefix))

##
##
define sm.fun.compute-object.
$(sm.var.temp._object_prefix)/$(basename $(subst ..,_,$(call sm-relative-path,$1))).o
endef #sm.fun.compute-object.

define sm.fun.compute-object.external
$(call sm.fun.compute-object.,$1)
endef #sm.fun.compute-object.external

##
## source file of relative location
define sm.fun.compute-source.
$(call sm-relative-path,$(sm.this.dir)/$(strip $1))
endef #sm.fun.compute-source.

##
## source file of fixed location
define sm.fun.compute-source.external
$(call sm-relative-path,$(strip $1))
endef #sm.fun.compute-source.external

##
## binary module to be built
define sm.fun.compute-module-targets-exe
$(call sm-relative-path,$(sm.out.bin))/$(sm.this.name)$(sm.this.suffix)
endef #sm.fun.compute-module-targets-exe

define sm.fun.compute-module-targets-t
$(call sm-relative-path,$(sm.out.bin))/$(sm.this.name)$(sm.this.suffix)
endef #sm.fun.compute-module-targets-t

define sm.fun.compute-module-targets-shared
$(call sm-relative-path,$(sm.out.bin))/$(sm.this.name)$(sm.this.suffix)
endef #sm.fun.compute-module-targets-shared

define sm.fun.compute-module-targets-static
$(call sm-relative-path,$(sm.out.lib))/lib$(sm.this.name:lib%=%)$(sm.this.suffix)
endef #sm.fun.compute-module-targets-static

##################################################

ifneq ($(and $(call is-true,$(sm.this.gen_deps)),\
             $(call not-equal,$(MAKECMDGOALS),clean)),)
## FIXME: $(sm.var.this).depends is always single!
## Make rule for source dependency
##   eg. $(call sm.fun.make-rule-depend)
##   eg. $(call sm.fun.make-rule-depend, external)
##   eg. $(call sm.fun.make-rule-depend, intermediate)
define sm.fun.make-rule-depend
  $(eval sm.var.temp._depend := $(sm.var.temp._object:%.o=%$(sm.var.depend.suffixes)))\
  $(eval $(sm.var.this).depends += $(sm.var.temp._depend))\
  $(eval \
    include $(sm.var.temp._depend)
    sm.args.output := $(sm.var.temp._depend)
    sm.args.target := $(sm.var.temp._object)
    sm.args.sources := $(call sm.fun.compute-source.$1,$(sm.var.temp._source))
    sm.args.flags.0 := $$($(sm.var.this).compile.$(sm.var.__module.compile_id).flags.$(sm.var.temp._lang))
    sm.args.flags.0 += $$(strip $(sm.this.compile.flags-$(sm.var.temp._source)))
    sm.args.flags.1 :=
    sm.args.flags.2 :=
  )$(sm-rule-dependency-$(sm.var.temp._lang))
endef #sm.fun.make-rule-depend
else
  sm.fun.make-rule-depend :=
endif #if sm.this.gen_deps && MAKECMDGOALS != clean

## FIXME: $(sm.var.this).objects is always single
## Make rule for building object
##   eg. $(call sm.fun.make-rule-compile)
##   eg. $(call sm.fun.make-rule-compile, external)
##   eg. $(call sm.fun.make-rule-compile, intermediate)
define sm.fun.make-rule-compile
 $(if $(sm.var.temp._lang),,$(error smart: internal: $$(sm.var.temp._lang) is empty))\
 $(if $(sm.var.temp._source),,$(error smart: internal: $$(sm.var.temp._source) is empty))\
 $(if $1,$(call sm-check-equal,$(strip $1),external,smart: arg \#3 must be 'external' if specified))\
 $(call sm-check-defined,sm.fun.compute-source.$(strip $1), smart: I donot know how to compute sources of lang '$(sm.var.temp._lang)$(if $1,($(strip $1)))')\
 $(call sm-check-defined,sm.fun.compute-object.$(strip $1), smart: I donot how to compute objects of lang '$(sm.var.temp._lang)$(if $1,($(strip $1)))')\
 $(call sm-check-defined,sm.fun.compute-flags-compile, smart: no callback for getting compile options of lang '$(sm.var.temp._lang)')\
 $(eval sm.var.temp._object := $(call sm.fun.compute-object.$(strip $1),$(sm.var.temp._source)))\
 $(eval $(sm.var.this).objects += $(sm.var.temp._object))\
 $(call sm.fun.make-rule-depend,$1)\
 $(call sm.fun.compute-flags-compile,$(sm.var.temp._lang))\
 $(eval \
   sm.args.target := $(sm.var.temp._object)
   sm.args.sources := $(call sm.fun.compute-source.$(strip $1),$(sm.var.temp._source))
   sm.args.flags.0 := $$(strip $$($(sm.var.this).compile.$(sm.var.__module.compile_id).flags.$(sm.var.temp._lang)))
   sm.args.flags.0 += $$(strip $(sm.this.compile.flags-$(sm.var.temp._source)))
   sm.args.flags.1 :=
   sm.args.flags.2 :=
 )$(if $(sm.this.sources.unknown),,$(sm-rule-compile-$(sm.var.temp._lang)))
endef #sm.fun.make-rule-compile

# TODO: smart conditional
# $(cond
#   (foo $(var-1))
#   (bar $(var-2))
#   (car $(var-3)))

##
## Produce code for make object rules
$(call sm-check-flavor, sm.fun.make-rule-compile, recursive)
define sm.code.make-rules-compile
 sm.var.temp._suffix_pat.$(sm.var.temp._lang)  := $$($(sm.var.toolset).$(sm.var.temp._lang).suffix:%=\%%)
 sm.this.sources.$(sm.var.temp._lang)          := $$(filter $$(sm.var.temp._suffix_pat.$(sm.var.temp._lang)),$$(sm.this.sources))
 sm.this.sources.external.$(sm.var.temp._lang) := $$(filter $$(sm.var.temp._suffix_pat.$(sm.var.temp._lang)),$$(sm.this.sources.external))
 sm.this.sources.has.$(sm.var.temp._lang)      := $$(if $$(sm.this.sources.$(sm.var.temp._lang))$$(sm.this.sources.external.$(sm.var.temp._lang)),true)
 ifeq ($$(sm.this.sources.has.$(sm.var.temp._lang)),true)
  $$(foreach sm.var.temp._source,$$(sm.this.sources.$(sm.var.temp._lang)),$$(call sm.fun.make-rule-compile))
  $$(foreach sm.var.temp._source,$$(sm.this.sources.external.$(sm.var.temp._lang)),$$(call sm.fun.make-rule-compile,external))
 endif
endef #sm.code.make-rules-compile

##
## Make object rules, eg. $(call sm.fun.make-rules-compile,c++)
##
## Computes sources of a specific languange via sm.var.temp._temp and generate
## compilation rules for them.
define sm.fun.make-rules-compile
$(if $(sm.var.temp._lang),,$(error smart: internal: sm.var.temp._lang is empty))\
$(eval $(sm.code.make-rules-compile))
endef #sm.fun.make-rules-compile

## Same as sm.fun.make-rules-compile, but the common source file like 'foo.w'
## may generate output like 'out/common/foo.cpp', this will be then appended
## to sm.this.sources.c++ which will then be used by sm.fun.make-rules-compile.
define sm.fun.make-rules-compile-common
$(if $(sm.var.temp._lang),,$(error smart: internal: sm.var.temp._lang is empty))\
$(warning TODO: object rules for $(sm.this.sources.$(sm.var.temp._lang)))
endef #sm.fun.make-rules-compile-common

##################################################

$(sm.var.this).targets :=

ifeq ($(sm.var.__module.compile_count),)
  ## in case that only sm-build-this (no sm-compile-sources) is called
  sm.var.__module.compile_count := 1
endif # $(sm.var.__module.compile_count) is empty

## If first time building this...
ifeq ($(sm.var.__module.compile_count),1)
  ## clear these vars only once (see sm-compile-sources)
  $(sm.var.this).sources :=
  $(sm.var.this).sources.unknown :=
  $(sm.var.this).objects := $(sm.this.objects)
  $(sm.var.this).depends :=
endif

#-----------------------------------------------
#-----------------------------------------------

## Returns true if $(sm.var.temp._source) is not supported by $(sm.this.toolset),
## and set variable sm.var.common.lang.XXX, where is the source suffix.
define sm.fun.is-strange-source
$(strip $(eval \
   sm.fun.is-strange-source.result :=
   ifeq ($(call not-equal,$(strip $(sm.toolset.for.file$(suffix $(sm.var.temp._source)))),$(strip $(sm.this.toolset))),true)
     sm.fun.is-strange-source.result := true
     $$(foreach _,$(sm.tool.common.langs),\
         $$(if $$(filter $(suffix $(sm.var.temp._source)),$$(sm.tool.common.$$_.suffix)),\
               $$(eval sm.fun.is-strange-source.result :=)\
               $$(eval sm.this.sources.common += $(sm.var.temp._source))\
               $$(eval sm.this.sources.$$_ += $(sm.var.temp._source))\
               $$(eval sm.var.common.langs += $$_)\
               $$(eval sm.var.common.lang$(suffix $(sm.var.temp._source)) := $$_)\
               $$(info smart: $$_: $(sm.var.temp._source))))
   endif
   $(null))$(sm.fun.is-strange-source.result))
endef #sm.fun.is-strange-source

## Check sources
sm.var.common.langs :=
sm.this.sources.common :=
sm.this.sources.unknown :=
$(foreach sm.var.temp._source,$(sm.this.sources)$(sm.this.sources.external),\
 $(if $(sm.fun.is-strange-source),\
     $(warning warning: "$(sm.var.temp._source)" is unsupported by toolset "$(sm.this.toolset)")\
     $(eval sm.this.sources.unknown += $(sm.var.temp._source))))

## Filter out %.t files, since it's not 'unknown'.
sm.this.sources.unknown := $(filter-out %.t,$(sm.this.sources.unknown))

## Export computed common sources.
sm.this.sources.common := $(strip $(sm.this.sources.common))
$(sm.var.this).sources.common := $(sm.this.sources.common)
$(foreach _,$(sm.var.common.langs),\
  $(eval $(sm.var.this).sources.$_ := $(sm.this.sources.$_)))

## Export unkown sources(FIXME: this may be no sense!)
$(sm.var.this).sources.unknown := $(sm.this.sources.unknown)

## Make object rules for common sources(files not handled by the toolset, e.g. .w, .nw, etc)
$(foreach sm.var.temp._lang,$(sm.var.common.langs),\
   $(if $(sm.tool.common.$(sm.var.temp._lang).suffix),\
      ,$(error smart: toolset $(sm.this.toolset)/$(sm.var.temp._lang) has no suffixes))\
   $(sm.fun.make-rules-compile-common))

## Make object rules for sources of different lang
$(foreach sm.var.temp._lang,$($(sm.var.toolset).langs),\
  $(if $($(sm.var.toolset).$(sm.var.temp._lang).suffix),\
      ,$(error smart: toolset $(sm.this.toolset)/$(sm.var.temp._lang) has no suffixes))\
  $(sm.fun.make-rules-compile)\
  $(if $(and $(call equal,$(strip $($(sm.var.this).lang)),),\
             $(sm.this.sources.has.$(sm.var.temp._lang))),\
         $(info smart: language choosed: $(sm.var.temp._lang))\
         $(eval $(sm.var.this).lang := $(sm.var.temp._lang))))\

## Make object rules for .t sources file
ifeq ($(sm.this.type),t)
  # set sm.var.temp._lang, used by sm.fun.make-rule-compile
  sm.var.temp._lang := $(sm.this.lang)
  sm.this.sources.$(sm.var.temp._lang).t := $(filter %.t,$(sm.this.sources))
  sm.this.sources.external.$(sm.var.temp._lang).t := $(filter %.t,$(sm.this.sources.external))
  sm.this.sources.has.$(sm.var.temp._lang).t := $(if $(sm.this.sources.$(sm.var.temp._lang).t)$(sm.this.sources.external.$(sm.var.temp._lang).t),true)
  ifeq ($(or $(sm.this.sources.has.$(sm.var.temp._lang)),$(sm.this.sources.has.$(sm.var.temp._lang).t)),true)
    $(call sm-check-flavor, sm.fun.make-rule-compile, recursive)
    $(foreach sm.var.temp._source,$(sm.this.sources.$(sm.var.temp._lang).t),$(call sm.fun.make-rule-compile))
    $(foreach sm.var.temp._source,$(sm.this.sources.external.$(sm.var.temp._lang).t),$(call sm.fun.make-rule-compile,external))
    ifeq ($($(sm.var.this).lang),)
      $(sm.var.this).lang := $(sm.this.lang)
    endif
  endif
endif

sm.var.temp._should_make_targets := \
  $(if $(or $(call not-equal,$(strip $(sm.this.sources.unknown)),),\
            $(call equal,$(strip $($(sm.var.this).objects)),),\
            $(call is-true,$(sm.var.__module.objects_only))\
        ),,true)

## Make rule for targets of the module
ifeq ($(sm.var.temp._should_make_targets),true)
$(if $($(sm.var.this).objects),,$(error smart: no objects for building '$(sm.this.name)'))
$(call sm-check-defined,sm.fun.compute-module-targets-$(sm.this.type))
$(eval $(sm.var.this).targets := $(strip $(call sm.fun.compute-module-targets-$(sm.this.type))))

$(call sm-check-defined,sm.var.action)
$(call sm-check-defined,$(sm.var.this).lang)
$(call sm-check-defined,sm-rule-$(sm.var.action)-$($(sm.var.this).lang))
$(call sm-check-defined,sm.fun.compute-flags-$(sm.var.action))
$(call sm-check-defined,sm.fun.compute-objects-$(sm.var.action))
$(call sm-check-defined,sm.fun.compute-libs-$(sm.var.action))

$(call sm.fun.compute-flags-$(sm.var.action))
$(call sm.fun.compute-objects-$(sm.var.action))
$(call sm.fun.compute-libs-$(sm.var.action))

$(call sm-check-defined,$(sm.var.this).$(sm.var.action).flags)
$(call sm-check-defined,$(sm.var.this).$(sm.var.action).objects)
$(call sm-check-defined,$(sm.var.this).$(sm.var.action).libs)
$(call sm-check-not-empty,$(sm.var.this).lang)

  sm.args.target := $($(sm.var.this).targets)
  sm.args.sources := $($(sm.var.this).objects)
  sm.args.flags.0 = $(if $(call is-true,$(sm.this.$(sm.var.action).flags.infile)),\
     ,$$($(sm.var.this).$(sm.var.action).flags))
  sm.args.flags.1 = $$($(sm.var.this).$(sm.var.action).libs)

  $(call sm-check-defined,sm-rule-$(sm.var.action)-$($(sm.var.this).lang))
  $(sm-rule-$(sm.var.action)-$($(sm.var.this).lang))

  ifeq ($(strip $($(sm.var.this).targets)),)
    $(error smart: internal error: targets mis-computed)
  endif
endif #sm.var.__module.objects_only

#-----------------------------------------------
#-----------------------------------------------

$(sm.var.this).user_defined_targets := $(strip $(sm.this.targets))
$(sm.var.this).module_targets := $($(sm.var.this).targets)
$(sm.var.this).targets += $($(sm.var.this).user_defined_targets)
sm.this.targets = $($(sm.var.this).targets)
sm.this.objects = $($(sm.var.this).objects)
sm.this.depends = $($(sm.var.this).depends)

#$(info $(sm.var.this).objects: $($(sm.var.this).objects))
#$(info $(sm.var.this).depends: $($(sm.var.this).depends))

##################################################
#ifneq ($(sm.var.__module.objects_only),true)
ifeq ($(sm.var.temp._should_make_targets),true)

ifeq ($(strip $($(sm.var.this).objects)),)
  $(warning smart: no objects)
endif

ifeq ($(MAKECMDGOALS),clean)
  goal-$(sm.this.name) : ; @true
else
  goal-$(sm.this.name) : \
    $($(sm.var.this).flag_files) \
    $(sm.this.depends) \
    $(sm.this.depends.copyfiles) \
    $($(sm.var.this).targets)
endif

ifeq ($(sm.this.type),t)
  define sm.code.make-test-rules
  sm.global.tests += test-$(sm.this.name)
  test-$(sm.this.name): $($(sm.var.this).targets)
	@echo test: $(sm.this.name) - $$< && $$<
  endef #sm.code.make-test-rules
  $(eval $(sm.code.make-test-rules))
endif

$(call sm-check-not-empty, sm.tool.common.rm)
$(call sm-check-not-empty, sm.tool.common.rmdir)

clean-$(sm.this.name): \
  clean-$(sm.this.name)-flags \
  clean-$(sm.this.name)-targets \
  clean-$(sm.this.name)-objects \
  clean-$(sm.this.name)-depends \
  $(sm.this.clean-steps)
	@echo "'$(@:clean-%=%)' is cleaned."

define sm.code.clean-rules
sm.rules.phony.* += \
    clean-$(sm.this.name) \
    clean-$(sm.this.name)-flags \
    clean-$(sm.this.name)-targets \
    clean-$(sm.this.name)-objects \
    clean-$(sm.this.name)-depends \
    $(sm.this.clean-steps)
clean-$(sm.this.name)-flags:
	$(if $(call is-true,$(sm.this.verbose)),,$$(info remove:$($(sm.var.this).targets))@)$$(call sm.tool.common.rm,$$($(sm.var.this).flag_files))
clean-$(sm.this.name)-targets:
	$(if $(call is-true,$(sm.this.verbose)),,$$(info remove:$($(sm.var.this).targets))@)$$(call sm.tool.common.rm,$$($(sm.var.this).targets))
clean-$(sm.this.name)-objects:
	$(if $(call is-true,$(sm.this.verbose)),,$$(info remove:$($(sm.var.this).objects))@)$$(call sm.tool.common.rm,$$($(sm.var.this).objects))
clean-$(sm.this.name)-depends:
	$(if $(call is-true,$(sm.this.verbose)),,$$(info remove:$($(sm.var.this).depends))@)$$(call sm.tool.common.rm,$$($(sm.var.this).depends))
endef #sm.code.clean-rules

$(eval $(sm.code.clean-rules))

endif # sm.var.temp._should_make_targets == true
#endif # sm.var.__module.objects_only
##################################################
