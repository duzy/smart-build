#

$(call sm-check-not-empty,sm.top)
$(call sm-check-not-empty,sm.this.dir)
$(call sm-check-not-empty,sm.this.name)
$(call sm-check-not-empty,sm.this.type)
$(call sm-check-not-empty,sm.this.toolset,smart: 'sm.this.toolset' for $(sm.this.name) unknown)

ifeq ($(sm.tool.$(sm.this.toolset)),)
  include $(sm.dir.buildsys)/loadtool.mk
endif

ifeq ($(sm.tool.$(sm.this.toolset)),)
  $(error smart: sm.tool.$(sm.this.toolset) is not defined)
endif

ifeq ($(sm.this.suffix),)
  $(call sm-check-defined,sm.tool.$(sm.this.toolset).target.suffix.$(sm.os.name).$(sm.this.type))
  sm.this.suffix := $(sm.tool.$(sm.this.toolset).target.suffix.$(sm.os.name).$(sm.this.type))
endif

$(call sm-check-value, sm.tool.$(sm.this.toolset), true, smart: toolset '$(sm.this.toolset)' is undefined)

ifeq ($(strip $(sm.this.sources)$(sm.this.sources.external)$(sm.this.objects)),)
  $(error smart: no sources for module '$(sm.this.name)')
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

sm.var.action.for.static := archive
sm.var.action.for.shared := link
sm.var.action.for.exe := link
sm.var.action.for.t := link

sm.var.prefix := sm.var.$(sm.this.name)

##########

## Clear compile options for all langs
$(foreach sm._var._temp._lang,$(sm.tool.$(sm.this.toolset).langs),\
  $(eval $(sm.var.prefix).compile.$(sm.var.__module.compile_id).flags.$(sm._var._temp._lang) := )\
  $(eval $(sm.var.prefix).compile.$(sm.var.__module.compile_id).flags.$(sm._var._temp._lang).assigned := ))

$(sm.var.prefix).archive.flags :=
$(sm.var.prefix).archive.flags.assigned :=
$(sm.var.prefix).archive.objects =
$(sm.var.prefix).archive.objects.assigned :=
$(sm.var.prefix).archive.libs :=
$(sm.var.prefix).archive.libs.assigned :=
$(sm.var.prefix).link.flags :=
$(sm.var.prefix).link.flags.assigned :=
$(sm.var.prefix).link.objects =
$(sm.var.prefix).link.objects.assigned :=
$(sm.var.prefix).link.libs :=
$(sm.var.prefix).link.libs.assigned :=

$(sm.var.prefix).flag_files :=

## eg. $(call sm.code.add-items,RESULT_VAR_NAME,ITEMS,PREFIX,SUFFIX)
define sm.code.add-items
 $(foreach sm._var._temp._item,$(strip $2),\
     $(eval $(strip $1) += $(strip $3)$(sm._var._temp._item:$(strip $3)%$(strip $4)=%)$(strip $4)))
endef #sm.code.add-items

## eg. $(call sm.code.shift-flags-to-file,compile,options.c++)
define sm.code.shift-flags-to-file-instant
$(if $1,,$(error smart: 'sm.code.shift-flags-to-file' action type in arg 1 is empty))\
$(if $2,,$(error smart: 'sm.code.shift-flags-to-file' needs options type in arg 2))\
$(if $(call is-true,$(sm.this.$1.flags.infile)),\
     $$(call sm-util-mkdir,$(sm.out.tmp)/$(sm.this.name))\
     $$(eval $(sm.var.prefix).$1.$2 := $$(subst \",\\\",$$($(sm.var.prefix).$1.$2)))\
     $$(shell echo $$($(sm.var.prefix).$1.$2) > $(sm.out.tmp)/$(sm.this.name)/$1.$2)\
     $$(eval $(sm.var.prefix).$1.$2 := @$(sm.out.tmp)/$(sm.this.name)/$1.$2))
endef #sm.code.shift-flags-to-file-instant


define sm.code-shift-flags-to-file-r
  $(sm.var.prefix).$1.$2.flat := $$(subst \",\\\",$$($(sm.var.prefix).$1.$2))
  $(sm.var.prefix).$1.$2 := @$(sm.out.tmp)/$(sm.this.name)/$1.$2
  $(sm.var.prefix).flag_files += $(sm.out.tmp)/$(sm.this.name)/$1.$2
  $(sm.out.tmp)/$(sm.this.name)/$1.$2: $(sm.this.makefile)
	@$$(info flags: $$@)
	@mkdir -p $(sm.out.tmp)/$(sm.this.name)
	@echo $$($(sm.var.prefix).$1.$2.flat) > $$@
#  $$(info $(sm.var.prefix).$1.$2 = $$($(sm.var.prefix).$1.$2))
#  $$(info $(sm.var.prefix).$1.$2.flat = $$($(sm.var.prefix).$1.$2.flat))
endef
## eg. $(call sm.code.shift-flags-to-file,compile,options.c++)
define sm.code.shift-flags-to-file
$(if $1,,$(error smart: 'sm.code.shift-flags-to-file' action type in arg 1 is empty))\
$(if $2,,$(error smart: 'sm.code.shift-flags-to-file' needs options type in arg 2))\
$(if $(call is-true,$(sm.this.$1.flags.infile)),\
   $$(eval $$(call sm.code-shift-flags-to-file-r,$(strip $1),$(strip $2))))
endef #sm.code.shift-flags-to-file

## eg. $(call sm.code.compute-options-compile,c++)
define sm.code.compute-options-compile
 $(sm.var.prefix).compile.$(sm.var.__module.compile_id).flags.$1.assigned := true
 $(sm.var.prefix).compile.$(sm.var.__module.compile_id).flags.$1 :=\
  $(if $(call equal,$(sm.this.type),t),-x$(sm.this.lang))\
  $(strip $(sm.tool.$(sm.this.toolset).defines))\
  $(strip $(sm.tool.$(sm.this.toolset).defines.$1))\
  $(strip $(sm.tool.$(sm.this.toolset).compile.flags))\
  $(strip $(sm.tool.$(sm.this.toolset).compile.flags.$1))\
  $(strip $(sm.global.defines))\
  $(strip $(sm.global.defines.$1))\
  $(strip $(sm.global.compile.flags))\
  $(strip $(sm.global.compile.flags.$1))\
  $(strip $(sm.this.defines))\
  $(strip $(sm.this.defines.$1))\
  $(strip $(sm.this.compile.flags))\
  $(strip $(sm.this.compile.flags.$1))
 $$(call sm.code.add-items, $(sm.var.prefix).compile.$(sm.var.__module.compile_id).flags.$1,\
     $(sm.global.includes) $(sm.this.includes), -I)
 $(call sm.code.shift-flags-to-file,compile,$(sm.var.__module.compile_id).flags.$1)
endef #sm.code.compute-options-compile

##
define sm.code.compute-options-link
 $(sm.var.prefix).link.flags.assigned := true
 $(sm.var.prefix).link.flags :=\
  $(strip $(sm.tool.$(sm.this.toolset).link.flags))\
  $(strip $(sm.global.link.flags))\
  $(strip $(sm.this.link.flags))
 $(if $(call equal,$(sm.this.type),shared),\
     $$(if $$(filter -shared,$$($(sm.var.prefix).link.flags)),,\
        $$(eval $(sm.var.prefix).link.flags += -shared)))
 $(call sm.code.shift-flags-to-file,link,options)
endef #sm.code.compute-options-link

define sm.code.compute-options-archive
 $(sm.var.prefix).archive.flags.assigned := true
 $(sm.var.prefix).archive.flags := \
  $(strip $(sm.global.archive.flags)) \
  $(strip $(sm.this.archive.flags))
 $(call sm.code.shift-flags-to-file,archive,options)
endef #sm.code.compute-options-archive

define sm.code.compute-objects-link
 $(sm.var.prefix).link.objects.assigned := true
 $(sm.var.prefix).link.objects := $($(sm.var.prefix).objects)
 $(call sm.code.shift-flags-to-file,link,objects)
endef #sm.code.compute-objects-link

define sm.code.compute-objects-archive
 $(sm.var.prefix).archive.objects.assigned := true
 $(sm.var.prefix).archive.objects := $($(sm.var.prefix).objects)
 $(call sm.code.shift-flags-to-file,archive,objects)
endef #sm.code.compute-objects-archive

##
define sm.code.compute-libs-link
 $(sm.var.prefix).link.libs.assigned := true
 $(sm.var.prefix).link.libs :=
 $$(call sm.code.add-items, $(sm.var.prefix).link.libs,\
     $(sm.global.libdirs) $(sm.this.libdirs), -L)
 $$(call sm.code.add-items, $(sm.var.prefix).link.libs,\
     $(sm.global.libs) $(sm.this.libs), -l)
 $(call sm.code.shift-flags-to-file,link,libs)
endef #sm.code.compute-libs-link

$(call sm-check-defined,sm.code.compute-options-compile, smart: 'sm.code.compute-options-compile' not defined)
$(call sm-check-defined,sm.code.compute-options-archive, smart: 'sm.code.compute-options-archive' not defined)
$(call sm-check-defined,sm.code.compute-options-link,	 smart: 'sm.code.compute-options-link' not defined)
$(call sm-check-defined,sm.code.compute-libs-link,       smart: 'sm.code.compute-libs-link' not defined)

define sm.fun.$(sm.this.name).compute-options-compile
$(if $($(sm.var.prefix).compile.$(sm.var.__module.compile_id).flags.$1.assigned),,\
   $(eval $(call sm.code.compute-options-compile,$1)))
endef #sm.fun.$(sm.this.name).compute-options-compile

define sm.fun.$(sm.this.name).compute-options-archive
 $(if $($(sm.var.prefix).archive.flags.assigned),,\
   $(eval $(call sm.code.compute-options-archive)))
endef #sm.fun.$(sm.this.name).compute-options-archive

define sm.fun.$(sm.this.name).compute-options-link
 $(if $($(sm.var.prefix).link.flags.assigned),,\
   $(eval $(call sm.code.compute-options-link)))
endef #sm.fun.$(sm.this.name).compute-options-link

define sm.fun.$(sm.this.name).compute-objects-archive
 $(if $($(sm.var.prefix).archive.objects.assigned),,\
   $(eval $(call sm.code.compute-objects-archive)))
endef #sm.fun.$(sm.this.name).compute-objects-archive

define sm.fun.$(sm.this.name).compute-libs-archive
 $(eval $(sm.var.prefix).archive.libs.assigned := true)\
 $(eval $(sm.var.prefix).archive.libs :=)
endef #sm.fun.$(sm.this.name).compute-libs-archive

define sm.fun.$(sm.this.name).compute-objects-link
 $(if $($(sm.var.prefix).link.objects.assigned),,\
   $(eval $(call sm.code.compute-objects-link)))
endef #sm.fun.$(sm.this.name).compute-objects-link

define sm.fun.$(sm.this.name).compute-libs-link
 $(if $($(sm.var.prefix).link.libs.assigned),,\
   $(eval $(call sm.code.compute-libs-link)))
endef #sm.fun.$(sm.this.name).compute-libs-link

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
define sm.fun.compute-module-targets-exe
$(call sm-to-relative-path,$(sm.out.bin))/$(sm.this.name)$(sm.this.suffix)
endef #sm.fun.compute-exe-module-targets

define sm.fun.compute-module-targets-t
$(call sm-to-relative-path,$(sm.out.bin))/$(sm.this.name)$(sm.this.suffix)
endef #sm.fun.compute-t-module-targets

define sm.fun.compute-module-targets-shared
$(call sm-to-relative-path,$(sm.out.bin))/$(sm.this.name)$(sm.this.suffix)
endef #sm.fun.compute-shared-module-targets

define sm.fun.compute-module-targets-static
$(call sm-to-relative-path,$(sm.out.lib))/lib$(sm.this.name:lib%=%)$(sm.this.suffix)
endef #sm.fun.compute-static-module-targets

##################################################

## Make rule for building object
##   eg. $(call sm.fun.make-object-rule, c++, foobar.cpp)
##   eg. $(call sm.fun.make-object-rule, c++, ~/sources/foobar.cpp, external)
define sm.fun.make-object-rule
 $(if $1,,$(error smart: arg \#1 must be the lang type))\
 $(if $2,,$(error smart: arg \#2 must be the source file))\
 $(if $3,$(call sm-check-equal,$(strip $3),external,smart: arg \#3 must be 'external' if specified))\
 $(call sm-check-defined,sm.fun.compute-source.$(strip $3), smart: I know how to compute sources of lang '$(strip $1)$(if $3,($(strip $3)))')\
 $(call sm-check-defined,sm.fun.compute-object.$(strip $3), smart: I know how to compute objects of lang '$(strip $1)$(if $3,($(strip $3)))')\
 $(call sm-check-defined,sm.fun.$(sm.this.name).compute-options-compile, smart: no callback for getting compile options of lang '$(strip $1)')\
 $(eval sm._var._temp._object := $(call sm.fun.compute-object.$(strip $3),$2))\
 $(eval $(sm.var.prefix).objects += $(sm._var._temp._object))\
 $(if $(and $(call is-true,$(sm.this.gen_deps)),\
            $(call not-equal,$(MAKECMDGOALS),clean)),\
      $(eval sm._var._temp._depend := $(sm._var._temp._object:%.o=%.d))\
      $(eval $(sm.var.prefix).depends += $(sm._var._temp._depend))\
      $(eval include $(sm._var._temp._depend))\
      $(call sm-rule-dependency-$(strip $1),\
         $(sm._var._temp._depend),$(sm._var._temp._object),\
         $(call sm.fun.compute-source.$(strip $3),$2),\
         $(sm.var.prefix).compile.$(sm.var.__module.compile_id).flags.$(strip $1)))\
 $(call sm.fun.$(sm.this.name).compute-options-compile,$(strip $1))\
 $(call sm-rule-compile-$(strip $1),\
    $(sm._var._temp._object),\
    $(call sm.fun.compute-source.$(strip $3),$2),\
    $(sm.var.prefix).compile.$(sm.var.__module.compile_id).flags.$(strip $1))
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
  $$(foreach _,$$(sm.this.sources.$1),$$(call sm.fun.make-object-rule,$1,$$_))
  $$(foreach _,$$(sm.this.sources.external.$1),$$(call sm.fun.make-object-rule,$1,$$_,external))
 endif
endef #sm.code.make-rules

##
## Make object rules, eg. $(call sm.fun.make-object-rules,c++)
define sm.fun.make-object-rules
$(eval $(sm.code.make-rules))
endef #sm.fun.make-object-rules

##################################################

$(sm.var.prefix).targets :=

ifeq ($(sm.var.__module.compile_count),1)
## clear these vars only once (see sm-compile-sources)
$(sm.var.prefix).objects := $(sm.this.objects)
$(sm.var.prefix).depends :=
else
ifeq ($(sm.var.__module.compile_count),)
## in case that only sm-build-this (no sm-compile-sources) is called
$(sm.var.prefix).objects := $(sm.this.objects)
$(sm.var.prefix).depends :=
endif
endif

## Make object rules for sources of different lang
$(foreach sm._var._temp._lang,$(sm.tool.$(sm.this.toolset).langs),\
  $(call sm.fun.make-object-rules,$(sm._var._temp._lang))\
  $(if $($(sm.var.prefix).lang),,\
    $(if $(sm.this.sources.has.$(sm._var._temp._lang)),\
         $(eval $(sm.var.prefix).lang := $(sm._var._temp._lang)))))

ifeq ($(sm.this.type),t)
  sm.this.sources.$(sm.this.lang).t := $(filter %.t,$(sm.this.sources))
  sm.this.sources.external.$(sm.this.lang).t := $(filter %.t,$(sm.this.sources.external))
  sm.this.sources.has.$(sm.this.lang).t := $(if $(sm.this.sources.$(sm.this.lang).t)$(sm.this.sources.external.$(sm.this.lang).t),true)
  ifeq ($(or $(sm.this.sources.has.$(sm.this.lang)),$(sm.this.sources.has.$(sm.this.lang).t)),true)
    $(call sm-check-flavor, sm.fun.make-object-rule, recursive)
    $(foreach _,$(sm.this.sources.$(sm.this.lang).t),$(call sm.fun.make-object-rule,$(sm.this.lang),$_))
    $(foreach _,$(sm.this.sources.external.$(sm.this.lang).t),$(call sm.fun.make-object-rule,$(sm.this.lang),$_,external))
    ifeq ($($(sm.var.prefix).lang),)
      $(sm.var.prefix).lang := $(sm.this.lang)
    endif
  endif
endif

#-----------------------------------------------
## Make rule for targets of the module
ifneq ($(sm.var.__module.objects_only),true)
$(if $($(sm.var.prefix).objects),,$(error smart: No objects for building '$(sm.this.name)'))
$(call sm-check-defined,sm.fun.compute-module-targets-$(sm.this.type))
$(eval $(sm.var.prefix).targets := $(strip $(call sm.fun.compute-module-targets-$(sm.this.type))))
$(call sm-check-defined,sm.var.action.for.$(sm.this.type))
$(call sm-check-defined,$(sm.var.prefix).lang)
$(call sm-check-defined,sm-rule-$(sm.var.action.for.$(sm.this.type))-$($(sm.var.prefix).lang))
$(call sm-check-defined,sm.fun.$(sm.this.name).compute-options-$(sm.var.action.for.$(sm.this.type)))
$(call sm-check-defined,sm.fun.$(sm.this.name).compute-objects-$(sm.var.action.for.$(sm.this.type)))
$(call sm-check-defined,sm.fun.$(sm.this.name).compute-libs-$(sm.var.action.for.$(sm.this.type)))
$(call sm.fun.$(sm.this.name).compute-options-$(sm.var.action.for.$(sm.this.type)))
$(call sm.fun.$(sm.this.name).compute-objects-$(sm.var.action.for.$(sm.this.type)))
$(call sm.fun.$(sm.this.name).compute-libs-$(sm.var.action.for.$(sm.this.type)))
$(call sm-check-defined,$(sm.var.prefix).$(sm.var.action.for.$(sm.this.type)).flags)
$(call sm-check-defined,$(sm.var.prefix).$(sm.var.action.for.$(sm.this.type)).objects)
$(call sm-check-defined,$(sm.var.prefix).$(sm.var.action.for.$(sm.this.type)).libs)
$(call sm-check-not-empty,$(sm.var.prefix).lang)
$(call sm-rule-$(sm.var.action.for.$(sm.this.type))-$($(sm.var.prefix).lang),\
   $$($(sm.var.prefix).targets),\
   $$($(sm.var.prefix).objects),\
   $(if $(call is-true,$(sm.this.$(sm.var.action.for.$(sm.this.type)).flags.infile)),\
     $($(sm.var.prefix).$(sm.var.action.for.$(sm.this.type)).objects)),\
   $(sm.var.prefix).$(sm.var.action.for.$(sm.this.type)).flags,\
   $(sm.var.prefix).$(sm.var.action.for.$(sm.this.type)).libs)

  ifeq ($(strip $($(sm.var.prefix).targets)),)
    $(error smart: internal error: targets mis-computed)
  endif
endif # sm.var.__module.objects_only
#-----------------------------------------------

# ifeq ($(strip $(sm.this.sources.c)$(sm.this.sources.c++)$(sm.this.sources.asm)),)
#   $(error smart: internal error: sources mis-computed)
# endif

ifeq ($(strip $($(sm.var.prefix).objects)),)
  $(error smart: internal error: objects mis-calculated)
endif

$(sm.var.prefix).user_defined_targets := $(strip $(sm.this.targets))
$(sm.var.prefix).module_targets := $($(sm.var.prefix).targets)
$(sm.var.prefix).targets += $($(sm.var.prefix).user_defined_targets)
sm.this.targets = $($(sm.var.prefix).targets)
sm.this.objects = $($(sm.var.prefix).objects)

##################################################
ifneq ($(sm.var.__module.objects_only),true)

ifeq ($(MAKECMDGOALS),clean)
  goal-$(sm.this.name) : ; @true
else
  goal-$(sm.this.name) : \
    $($(sm.var.prefix).flag_files) \
    $(sm.this.depends) \
    $(sm.this.depends.copyfiles) \
    $($(sm.var.prefix).targets)
endif

ifeq ($(sm.this.type),t)
  define sm.code.make-test-rules
  sm.global.tests += test-$(sm.this.name)
  test-$(sm.this.name): $($(sm.var.prefix).targets)
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
	$(if $(call is-true,$(sm.this.verbose)),,$$(info remove:$($(sm.var.prefix).targets))@)$$(call sm.tool.common.rm,$$($(sm.var.prefix).flag_files))
clean-$(sm.this.name)-targets:
	$(if $(call is-true,$(sm.this.verbose)),,$$(info remove:$($(sm.var.prefix).targets))@)$$(call sm.tool.common.rm,$$($(sm.var.prefix).targets))
clean-$(sm.this.name)-objects:
	$(if $(call is-true,$(sm.this.verbose)),,$$(info remove:$($(sm.var.prefix).objects))@)$$(call sm.tool.common.rm,$$($(sm.var.prefix).objects))
clean-$(sm.this.name)-depends:
	$(if $(call is-true,$(sm.this.verbose)),,$$(info remove:$($(sm.var.prefix).depends))@)$$(call sm.tool.common.rm,$$($(sm.var.prefix).depends))
endef #sm.code.clean-rules

$(eval $(sm.code.clean-rules))

endif # sm.var.__module.objects_only
##################################################
