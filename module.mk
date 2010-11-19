#

$(call sm-check-not-empty,sm.top)
$(call sm-check-not-empty,sm.this.dir)
$(call sm-check-not-empty,sm.this.name)
$(call sm-check-not-empty,sm.this.type)
$(call sm-check-not-empty,sm.this.toolset,smart: 'sm.this.toolset' unknown)

ifeq ($(strip $(sm.this.sources)$(sm.this.sources.external)),)
  $(error smart: no sources for module '$(sm.this.name)')
endif

##################################################

ifeq ($(sm.this.type),t)
 $(if $(sm.this.lang),,$(error smart: 'sm.this.lang' must be defined for tests module))
endif

define sm.code.check-infile
ifeq ($$(call is-true,$$(sm.this.$1.flags.infile)),true)
  ifeq ($$(sm.this.$1.options.infile),)
    sm.this.$1.options.infile := true
  else
    $$(error smart: 'sm.this.$1.options.infile' and 'sm.this.$1.flags.infile' mismatched)
  endif
endif
endef #sm.code.check-infile

$(foreach a,compile archive link,$(eval $(call sm.code.check-infile,$a)))

##################################################

sm.var.build_action.static := archive
sm.var.build_action.shared := link
sm.var.build_action.exe := link
sm.var.build_action.t := link

##########

## Clear compile options for all langs
$(foreach sm._var._temp._lang,$(sm.tool.$(sm.this.toolset).langs),\
  $(eval sm.var.$(sm.this.name).compile.$(sm.var.__module.compile_id).options.$(sm._var._temp._lang) := )\
  $(eval sm.var.$(sm.this.name).compile.$(sm.var.__module.compile_id).options.$(sm._var._temp._lang).assigned := ))

sm.var.$(sm.this.name).archive.options :=
sm.var.$(sm.this.name).archive.options.assigned :=
sm.var.$(sm.this.name).archive.objects =
sm.var.$(sm.this.name).archive.objects.assigned :=
sm.var.$(sm.this.name).archive.libs :=
sm.var.$(sm.this.name).archive.libs.assigned :=
sm.var.$(sm.this.name).link.options :=
sm.var.$(sm.this.name).link.options.assigned :=
sm.var.$(sm.this.name).link.objects =
sm.var.$(sm.this.name).link.objects.assigned :=
sm.var.$(sm.this.name).link.libs :=
sm.var.$(sm.this.name).link.libs.assigned :=

## eg. $(call sm.code.add-items,RESULT_VAR_NAME,ITEMS,PREFIX,SUFFIX)
define sm.code.add-items
 $(foreach sm._var._temp._item,$(strip $2),\
     $(eval $(strip $1) += $(strip $3)$(sm._var._temp._item:$(strip $3)%$(strip $4)=%)$(strip $4)))
endef #sm.code.add-items

## eg. $(call sm.code.shift-options-to-file,compile,options.c++)
define sm.code.shift-options-to-file
$(if $2,,$(error smart: 'sm.code.shift-options-to-file' needs options type in arg \#2))\
$(if $(call is-true,$(sm.this.$1.options.infile)),\
     $$(call sm-util-mkdir,$(sm.out.tmp)/$(sm.this.name))\
     $$(eval sm.var.$(sm.this.name).$1.$2 := $$(subst \",\\\",$$(sm.var.$(sm.this.name).$1.$2)))\
     $$(shell echo $$(sm.var.$(sm.this.name).$1.$2) > $(sm.out.tmp)/$(sm.this.name)/$1.$2)\
     $$(eval sm.var.$(sm.this.name).$1.$2 := @$(sm.out.tmp)/$(sm.this.name)/$1.$2))
endef #sm.code.shift-options-to-file

## eg. $(call sm.code.compute-compile-options,c++)
define sm.code.compute-compile-options
 sm.var.$(sm.this.name).compile.$(sm.var.__module.compile_id).options.$1.assigned := true
 sm.var.$(sm.this.name).compile.$(sm.var.__module.compile_id).options.$1 := $(if $(call equal,$(sm.this.type),t),-x$(sm.this.lang))\
  $(strip $(sm.tool.$(sm.this.toolset).compile.flags) $(sm.tool.$(sm.this.toolset).compile.options)) \
  $(strip $(sm.tool.$(sm.this.toolset).compile.flags.$1) $(sm.tool.$(sm.this.toolset).compile.options.$1)) \
  $(strip $(sm.global.compile.flags) $(sm.global.compile.options)) \
  $(strip $(sm.global.compile.flags.$1) $(sm.global.compile.options.$1)) \
  $(strip $(sm.this.compile.flags) $(sm.this.compile.options)) \
  $(strip $(sm.this.compile.flags.$1) $(sm.this.compile.options.$1))
 $$(call sm.code.add-items, sm.var.$(sm.this.name).compile.$(sm.var.__module.compile_id).options.$1, $(sm.global.includes), -I)
 $$(call sm.code.add-items, sm.var.$(sm.this.name).compile.$(sm.var.__module.compile_id).options.$1, $(sm.this.includes), -I)
 $(call sm.code.shift-options-to-file,compile,$(sm.var.__module.compile_id).options.$1)
endef #sm.code.compute-compile-options

##
define sm.code.compute-link-options
 sm.var.$(sm.this.name).link.options.assigned := true
 sm.var.$(sm.this.name).link.options := \
  $(strip $(sm.tool.$(sm.this.toolset).link.flags) $(sm.tool.$(sm.this.toolset).link.options)) \
  $(strip $(sm.global.link.flags) $(sm.global.link.options)) \
  $(strip $(sm.this.link.flags) $(sm.this.link.options))
 $(if $(call equal,$(sm.this.type),shared),\
     $$(if $$(filter -shared,$$(sm.var.$(sm.this.name).link.options)),,\
        $$(eval sm.var.$(sm.this.name).link.options += -shared)))
 $(call sm.code.shift-options-to-file,link,options)
endef #sm.code.compute-link-options

define sm.code.compute-archive-options
 sm.var.$(sm.this.name).archive.options.assigned := true
 sm.var.$(sm.this.name).archive.options := \
  $(strip $(sm.global.archive.flags) $(sm.global.archive.options)) \
  $(strip $(sm.this.archive.flags) $(sm.this.archive.options))
 $(call sm.code.shift-options-to-file,archive,options)
endef #sm.code.compute-archive-options

define sm.code.compute-link-objects
 sm.var.$(sm.this.name).link.objects.assigned := true
 sm.var.$(sm.this.name).link.objects := $(sm.var.$(sm.this.name).objects)
 $(call sm.code.shift-options-to-file,link,objects)
endef #sm.code.compute-link-objects

define sm.code.compute-archive-objects
 sm.var.$(sm.this.name).archive.objects.assigned := true
 sm.var.$(sm.this.name).link.objects := $(sm.var.$(sm.this.name).objects)
 $(call sm.code.shift-options-to-file,archive,objects)
endef #sm.code.compute-archive-objects

##
define sm.code.compute-link-libs
 sm.var.$(sm.this.name).link.libs.assigned := true
 sm.var.$(sm.this.name).link.libs :=
 $$(call sm.code.add-items, sm.var.$(sm.this.name).link.libs, $(sm.global.libdirs), -L)
 $$(call sm.code.add-items, sm.var.$(sm.this.name).link.libs, $(sm.this.libdirs), -L)
 $$(call sm.code.add-items, sm.var.$(sm.this.name).link.libs, $(sm.global.libs), -l)
 $$(call sm.code.add-items, sm.var.$(sm.this.name).link.libs, $(sm.this.libs), -l)
 $(call sm.code.shift-options-to-file,link,libs)
endef #sm.code.compute-link-libs
#  $(if $(call is-true,$(sm.this.link.options.infile)),\
#      $$(call sm-util-mkdir,$(sm.out.tmp)/$(sm.this.name))\
#      $$(eval sm.var.$(sm.this.name).link.libs := $$(subst \",\\\",$$(sm.var.$(sm.this.name).link.libs)))\
#      $$(shell echo $$(sm.var.$(sm.this.name).link.libs) > $(sm.out.tmp)/$(sm.this.name)/link.libs)\
#      $$(eval sm.var.$(sm.this.name).link.libs := @$(sm.out.tmp)/$(sm.this.name)/link.libs))

## TODO: something like switch-objects-into-file for linking and archiving

$(call sm-check-defined,sm.code.compute-compile-options, smart: 'sm.code.compute-compile-options' not defined)
$(call sm-check-defined,sm.code.compute-archive-options, smart: 'sm.code.compute-archive-options' not defined)
$(call sm-check-defined,sm.code.compute-link-options,	 smart: 'sm.code.compute-link-options' not defined)
$(call sm-check-defined,sm.code.compute-link-libs,       smart: 'sm.code.compute-link-libs' not defined)

define sm.fun.$(sm.this.name).compute-compile-options
$(if $(sm.var.$(sm.this.name).compile.$(sm.var.__module.compile_id).options.$1.assigned),,\
   $(eval $(call sm.code.compute-compile-options,$1)))
endef #sm.fun.$(sm.this.name).compute-compile-options

define sm.fun.$(sm.this.name).compute-archive-options
 $(if $(sm.var.$(sm.this.name).archive.options.assigned),,\
   $(eval $(call sm.code.compute-archive-options)))
endef #sm.fun.$(sm.this.name).compute-archive-options

define sm.fun.$(sm.this.name).compute-link-options
 $(if $(sm.var.$(sm.this.name).link.options.assigned),,\
   $(eval $(call sm.code.compute-link-options)))
endef #sm.fun.$(sm.this.name).compute-link-options

define sm.fun.$(sm.this.name).compute-archive-objects
 $(if $(sm.var.$(sm.this.name).archive.objects.assigned),,\
   $(eval $(call sm.code.compute-archive-objects)))
endef #sm.fun.$(sm.this.name).compute-archive-objects

define sm.fun.$(sm.this.name).compute-archive-libs
 $(eval sm.var.$(sm.this.name).archive.libs.assigned := true)\
 $(eval sm.var.$(sm.this.name).archive.libs :=)
endef #sm.fun.$(sm.this.name).compute-archive-libs

define sm.fun.$(sm.this.name).compute-link-objects
 $(if $(sm.var.$(sm.this.name).link.objects.assigned),,\
   $(eval $(call sm.code.compute-link-objects)))
endef #sm.fun.$(sm.this.name).compute-link-objects

define sm.fun.$(sm.this.name).compute-link-libs
 $(if $(sm.var.$(sm.this.name).link.libs.assigned),,\
   $(eval $(call sm.code.compute-link-libs)))
endef #sm.fun.$(sm.this.name).compute-link-libs

##################################################

## The output object file prefix
sm._var._temp._object_prefix := \
  $(call sm-to-relative-path,$(sm.out.obj))$(sm.this.dir:$(sm.top)%=%)

## Fixes the prefix for 'out/debug/obj.' like value
sm._var._temp._object_prefix := $(sm._var._temp._object_prefix:%.=%)

# BUG: wrong if more than one sm-build-this occurs in a smart.mk
#$(warning $(sm.this.name): $(sm._var._temp._object_prefix))

##
##
define sm.fun.compute-object.
$(sm._var._temp._object_prefix)/$(basename $(subst ..,_,$(call sm-to-relative-path,$1))).o
endef #sm.fun.compute-object.

define sm.fun.compute-object.external
$(call sm.fun.compute-object.,$1)
endef #sm.fun.compute-object.external

##
## source file of relative location
define sm.fun.compute-source.
$(call sm-to-relative-path,$(sm.this.dir)/$(strip $1))
endef #sm.fun.compute-source.

##
## source file of fixed location
define sm.fun.compute-source.external
$(call sm-to-relative-path,$(strip $1))
endef #sm.fun.compute-source.external

##
## binary module to be built
define sm.fun.compute-exe-module-targets
$(call sm-to-relative-path,$(sm.out.bin))/$(sm.this.name)$(sm.this.suffix)
endef #sm.fun.compute-exe-module-targets

define sm.fun.compute-t-module-targets
$(call sm-to-relative-path,$(sm.out.bin))/$(sm.this.name)$(sm.this.suffix)
endef #sm.fun.compute-t-module-targets

define sm.fun.compute-shared-module-targets
$(call sm-to-relative-path,$(sm.out.bin))/$(sm.this.name)$(sm.this.suffix)
endef #sm.fun.compute-shared-module-targets

define sm.fun.compute-static-module-targets
$(call sm-to-relative-path,$(sm.out.lib))/lib$(sm.this.name:lib%=%)$(sm.this.suffix)
endef #sm.fun.compute-static-module-targets

##################################################

# TODO: move $(call sm.fun.$(sm.this.name).compute-compile-options,$(strip $1)) into sm.fun.make-object-rules
## Make rule for building object
##   eg. $(call sm.fun.make-object-rule, c++, foobar.cpp)
##   eg. $(call sm.fun.make-object-rule, c++, ~/sources/foobar.cpp, external)
define sm.fun.make-object-rule
 $(if $1,,$(error smart: arg \#1 must be the lang type))\
 $(if $2,,$(error smart: arg \#2 must be the source file))\
 $(if $3,$(call sm-check-equal,$(strip $3),external,smart: arg \#3 must be 'external' if specified))\
 $(call sm-check-defined,sm.fun.compute-source.$(strip $3), smart: I know how to compute sources of lang '$(strip $1)$(if $3,($(strip $3)))')\
 $(call sm-check-defined,sm.fun.compute-object.$(strip $3), smart: I know how to compute objects of lang '$(strip $1)$(if $3,($(strip $3)))')\
 $(call sm-check-defined,sm.fun.$(sm.this.name).compute-compile-options, smart: no callback for getting compile options of lang '$(strip $1)')\
 $(eval sm._var._temp._object := $(call sm.fun.compute-object.$(strip $3),$2))\
 $(eval sm.var.$(sm.this.name).objects += $(sm._var._temp._object))\
 $(if $(call is-true,$(sm.this.gen_deps)),\
      $(eval sm._var._temp._depend := $(sm._var._temp._object:%.o=%.d))\
      $(eval sm.var.$(sm.this.name).depends += $(sm._var._temp._depend))\
      $(eval include $(sm._var._temp._depend))\
      $(call sm.rule.dependency.$(strip $1),\
         $(sm._var._temp._depend),$(sm._var._temp._object),\
         $(call sm.fun.compute-source.$(strip $3),$2),\
         sm.var.$(sm.this.name).compile.$(sm.var.__module.compile_id).options.$(strip $1)))\
 $(call sm.fun.$(sm.this.name).compute-compile-options,$(strip $1))\
 $(call sm.rule.compile.$(strip $1),\
    $(sm._var._temp._object),\
    $(call sm.fun.compute-source.$(strip $3),$2),\
    sm.var.$(sm.this.name).compile.$(sm.var.__module.compile_id).options.$(strip $1))
endef #sm.fun.make-object-rule

##
## Produce code for make object rules
define sm.code.make-rules
$(if $1,,$(error smart: arg \#1 must be lang-type))\
$(if $(sm.tool.$(sm.this.toolset).$1.suffix),,$(error smart: no registered suffixes for $(sm.this.toolset)/$1))\
 sm._var._temp._suffix.$1 := $$(sm.tool.$(sm.this.toolset).$1.suffix:%=\%%)
 sm.this.sources.$1 := $$(filter $$(sm._var._temp._suffix.$1),$$(sm.this.sources))
 sm.this.sources.external.$1 := $$(filter $$(sm._var._temp._suffix.$1),$$(sm.this.sources.external))
 sm.this.sources.has.$1 := $$(if $$(sm.this.sources.$1)$$(sm.this.sources.external.$1),true,)
 ifeq ($$(sm.this.sources.has.$1),true)
  $$(call sm-check-flavor, sm.fun.make-object-rule, recursive)
  $$(foreach s,$$(sm.this.sources.$1),$$(call sm.fun.make-object-rule,$1,$$s))
  $$(foreach s,$$(sm.this.sources.external.$1),$$(call sm.fun.make-object-rule,$1,$$s,external))
 endif
endef #sm.code.make-rules

##
## Make object rules, eg. $(call sm.fun.make-object-rules,c++)
define sm.fun.make-object-rules
$(eval $(call sm.code.make-rules,$(strip $1)))
endef #sm.fun.make-object-rules

##
## Make module build rule
define sm.fun.make-target-rule
  $(if $(sm.var.$(sm.this.name).objects),,$(error smart: No objects for building '$(sm.this.name)'))\
  $(call sm-check-defined,sm.fun.compute-$(sm.this.type)-module-targets)\
  $(eval sm.var.$(sm.this.name).targets := $(strip $(call sm.fun.compute-$(sm.this.type)-module-targets)))\
  $(call sm-check-defined,sm.var.build_action.$(sm.this.type))\
  $(call sm-check-defined,sm.var.$(sm.this.name).lang)\
  $(call sm-check-defined,sm.rule.$(sm.var.build_action.$(sm.this.type)).$(sm.var.$(sm.this.name).lang))\
  $(call sm-check-defined,sm.fun.$(sm.this.name).compute-$(sm.var.build_action.$(sm.this.type))-options)\
  $(call sm-check-defined,sm.fun.$(sm.this.name).compute-$(sm.var.build_action.$(sm.this.type))-objects)\
  $(call sm-check-defined,sm.fun.$(sm.this.name).compute-$(sm.var.build_action.$(sm.this.type))-libs)\
  $(call sm.fun.$(sm.this.name).compute-$(sm.var.build_action.$(sm.this.type))-options)\
  $(call sm.fun.$(sm.this.name).compute-$(sm.var.build_action.$(sm.this.type))-objects)\
  $(call sm.fun.$(sm.this.name).compute-$(sm.var.build_action.$(sm.this.type))-libs)\
  $(call sm-check-defined,sm.var.$(sm.this.name).$(sm.var.build_action.$(sm.this.type)).options)\
  $(call sm-check-defined,sm.var.$(sm.this.name).$(sm.var.build_action.$(sm.this.type)).objects)\
  $(call sm-check-defined,sm.var.$(sm.this.name).$(sm.var.build_action.$(sm.this.type)).libs)\
  $(call sm-check-not-empty,sm.var.$(sm.this.name).lang)\
  $(call sm.rule.$(sm.var.build_action.$(sm.this.type)).$(sm.var.$(sm.this.name).lang),\
     $$(sm.var.$(sm.this.name).targets),\
     $$(sm.var.$(sm.this.name).objects),\
     $(if $(call is-true,$(sm.this.$(sm.var.build_action.$(sm.this.type)).options.infile)),\
       $(sm.var.$(sm.this.name).$(sm.var.build_action.$(sm.this.type)).objects)),\
     sm.var.$(sm.this.name).$(sm.var.build_action.$(sm.this.type)).options,\
     sm.var.$(sm.this.name).$(sm.var.build_action.$(sm.this.type)).libs)
endef #sm.fun.make-target-rule

#sm.var.$(sm.this.name).$(sm.var.build_action.$(sm.this.type)).objects

##################################################

sm.var.$(sm.this.name).targets :=
ifeq (true,false)
## donot clear these vars for sm-compile-sources
sm.var.$(sm.this.name).objects :=
sm.var.$(sm.this.name).depends :=
endif

## Make object rules for sources of different lang
$(foreach sm._var._temp._lang,$(sm.tool.$(sm.this.toolset).langs),\
  $(call sm.fun.make-object-rules,$(sm._var._temp._lang))\
  $(if $(sm.var.$(sm.this.name).lang),,\
    $(if $(sm.this.sources.has.$(sm._var._temp._lang)),\
         $(eval sm.var.$(sm.this.name).lang := $(sm._var._temp._lang)))))

ifeq ($(sm.this.type),t)
  sm.this.sources.$(sm.this.lang).t := $(filter %.t,$(sm.this.sources))
  sm.this.sources.external.$(sm.this.lang).t := $(filter %.t,$(sm.this.sources.external))
  sm.this.sources.has.$(sm.this.lang).t := $(if $(sm.this.sources.$(sm.this.lang).t)$(sm.this.sources.external.$(sm.this.lang).t),true)
  ifeq ($(or $(sm.this.sources.has.$(sm.this.lang)),$(sm.this.sources.has.$(sm.this.lang).t)),true)
    $(call sm-check-flavor, sm.fun.make-object-rule, recursive)
    $(foreach t,$(sm.this.sources.$(sm.this.lang).t),$(call sm.fun.make-object-rule,$(sm.this.lang),$t))
    $(foreach t,$(sm.this.sources.external.$(sm.this.lang).t),$(call sm.fun.make-object-rule,$(sm.this.lang),$t,external))
    ifeq ($(sm.var.$(sm.this.name).lang),)
      sm.var.$(sm.this.name).lang := $(sm.this.lang)
    endif
  endif
endif

#-----------------------------------------------
## Make rule for targets of the module
ifneq ($(sm.var.__module.objects_only),true)
#$(call sm.fun.make-target-rule)
$(if $(sm.var.$(sm.this.name).objects),,$(error smart: No objects for building '$(sm.this.name)'))
$(call sm-check-defined,sm.fun.compute-$(sm.this.type)-module-targets)
$(eval sm.var.$(sm.this.name).targets := $(strip $(call sm.fun.compute-$(sm.this.type)-module-targets)))
$(call sm-check-defined,sm.var.build_action.$(sm.this.type))
$(call sm-check-defined,sm.var.$(sm.this.name).lang)
$(call sm-check-defined,sm.rule.$(sm.var.build_action.$(sm.this.type)).$(sm.var.$(sm.this.name).lang))
$(call sm-check-defined,sm.fun.$(sm.this.name).compute-$(sm.var.build_action.$(sm.this.type))-options)
$(call sm-check-defined,sm.fun.$(sm.this.name).compute-$(sm.var.build_action.$(sm.this.type))-objects)
$(call sm-check-defined,sm.fun.$(sm.this.name).compute-$(sm.var.build_action.$(sm.this.type))-libs)
$(call sm.fun.$(sm.this.name).compute-$(sm.var.build_action.$(sm.this.type))-options)
$(call sm.fun.$(sm.this.name).compute-$(sm.var.build_action.$(sm.this.type))-objects)
$(call sm.fun.$(sm.this.name).compute-$(sm.var.build_action.$(sm.this.type))-libs)
$(call sm-check-defined,sm.var.$(sm.this.name).$(sm.var.build_action.$(sm.this.type)).options)
$(call sm-check-defined,sm.var.$(sm.this.name).$(sm.var.build_action.$(sm.this.type)).objects)
$(call sm-check-defined,sm.var.$(sm.this.name).$(sm.var.build_action.$(sm.this.type)).libs)
$(call sm-check-not-empty,sm.var.$(sm.this.name).lang)
$(call sm.rule.$(sm.var.build_action.$(sm.this.type)).$(sm.var.$(sm.this.name).lang),\
   $$(sm.var.$(sm.this.name).targets),\
   $$(sm.var.$(sm.this.name).objects),\
   $(if $(call is-true,$(sm.this.$(sm.var.build_action.$(sm.this.type)).options.infile)),\
     $(sm.var.$(sm.this.name).$(sm.var.build_action.$(sm.this.type)).objects)),\
   sm.var.$(sm.this.name).$(sm.var.build_action.$(sm.this.type)).options,\
   sm.var.$(sm.this.name).$(sm.var.build_action.$(sm.this.type)).libs)

  ifeq ($(strip $(sm.var.$(sm.this.name).targets)),)
    $(error smart: internal error: targets mis-computed)
  endif
endif # sm.var.__module.objects_only
#-----------------------------------------------

# ifeq ($(strip $(sm.this.sources.c)$(sm.this.sources.c++)$(sm.this.sources.asm)),)
#   $(error smart: internal error: sources mis-computed)
# endif

ifeq ($(strip $(sm.var.$(sm.this.name).objects)),)
  $(error smart: internal error: objects mis-calculated)
endif

sm.this.targets = $(sm.var.$(sm.this.name).targets)
sm.this.objects = $(sm.var.$(sm.this.name).objects)
sm.this.depends = $(sm.var.$(sm.this.name).depends)

##################################################
ifneq ($(sm.var.__module.objects_only),true)

ifeq ($(sm.this.type),t)
  define sm.code.make-test-rules
  sm.global.tests += test-$(sm.this.name)
  test-$(sm.this.name): $(sm.var.$(sm.this.name).targets)
	@echo test: $(sm.this.name) - $$< && $$<
  endef #sm.code.make-test-rules
  $(eval $(sm.code.make-test-rules))
endif

$(call sm-check-not-empty, sm.tool.common.rm)
$(call sm-check-not-empty, sm.tool.common.rmdir)

clean-$(sm.this.name): \
  clean-$(sm.this.name)-targets \
  clean-$(sm.this.name)-objects \
  clean-$(sm.this.name)-depends
	@echo "'$(@:clean-%=%)' is cleaned."

define sm.code.make-clean-rules
  sm.rules.phony.* += \
    clean-$(sm.this.name) \
    clean-$(sm.this.name)-targets \
    clean-$(sm.this.name)-objects \
    clean-$(sm.this.name)-depends

  clean-$(sm.this.name)-targets:
	$(if $(call is-true,$(sm.this.verbose)),,$$(info remove:$(sm.var.$(sm.this.name).targets))@)$$(call sm.tool.common.rm,$$(sm.var.$(sm.this.name).targets))
  clean-$(sm.this.name)-objects:
	$(if $(call is-true,$(sm.this.verbose)),,$$(info remove:$(sm.var.$(sm.this.name).objects))@)$$(call sm.tool.common.rm,$$(sm.var.$(sm.this.name).objects))
  clean-$(sm.this.name)-depends:
	$(if $(call is-true,$(sm.this.verbose)),,$$(info remove:$(sm.var.$(sm.this.name).depends))@)$$(call sm.tool.common.rm,$$(sm.var.$(sm.this.name).depends))
endef #sm.code.make-clean-rules

$(eval $(sm.code.make-clean-rules))

endif # sm.var.__module.objects_only
##################################################
