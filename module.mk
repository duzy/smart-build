#

$(call sm-check-not-empty,sm.top)
$(call sm-check-not-empty,sm.this.toolset,smart: Must set 'sm.this.toolset')

ifeq ($(strip $(sm.this.sources)$(sm.this.sources.external)),)
  $(error smart: no sources for module '$(sm.this.name)')
endif

##################################################

## TODO: unit test module
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

$(foreach sm._var._temp._lang,$(sm.tool.$(sm.this.toolset).langs),\
  $(eval sm.var.$(sm.this.name).compile.options.$(sm._var._temp._lang) := ))

sm.var.$(sm.this.name).archive.options :=
sm.var.$(sm.this.name).link.options :=
sm.var.$(sm.this.name).link.libs :=

##
define sm.code.calculate-includes
 $(foreach sm._var._temp._include,$($(strip $2)),\
   $(eval sm.var.$(sm.this.name).compile.options.$(strip $1) += -I$$(sm._var._temp._include:-I%=%)))
endef #sm.code.calculate-includes

##
define sm.code.switch-options-into-file
$(if $(call is-true,$(sm.this.$1.options.infile)),\
     $$(call sm-util-mkdir,$(sm.dir.out.tmp)/$(sm.this.name))\
     $$(eval sm.var.$(sm.this.name).$1.options$2 := $$(subst \",\\\",$$(sm.var.$(sm.this.name).$1.options$2)))\
     $$(shell echo $$(sm.var.$(sm.this.name).$1.options$2) > $(sm.dir.out.tmp)/$(sm.this.name)/$1.options$2)\
     $$(eval sm.var.$(sm.this.name).$1.options$2 := @$(sm.dir.out.tmp)/$(sm.this.name)/$1.options$2))
endef #sm.code.switch-options-into-file

##
define sm.code.calculate-compile-options
 sm.var.$(sm.this.name).compile.options.$1 := \
  $(strip $(sm.global.compile.flags) $(sm.global.compile.options)) \
  $(strip $(sm.global.compile.flags.$1) $(sm.global.compile.options.$1)) \
  $(strip $(sm.this.compile.flags) $(sm.this.compile.options)) \
  $(strip $(sm.this.compile.flags.$1) $(sm.this.compile.options.$1))
 $$(call sm.code.calculate-includes,$1,sm.global.includes)
 $$(call sm.code.calculate-includes,$1,sm.this.includes)
 $(call sm.code.switch-options-into-file,compile,.$1)
endef #sm.code.calculate-compile-options

##
define sm.code.calculate-link-options
 sm.var.$(sm.this.name).link.options := \
  $(strip $(sm.global.link.flags) $(sm.global.link.options)) \
  $(strip $(sm.this.link.flags) $(sm.this.link.options))
 $(call sm.code.switch-options-into-file,link)
endef #sm.code.calculate-link-options

define sm.code.calculate-archive-options
 sm.var.$(sm.this.name).archive.options := \
  $(strip $(sm.global.archive.flags) $(sm.global.archive.options)) \
  $(strip $(sm.this.archive.flags) $(sm.this.archive.options))
 $(call sm.code.switch-options-into-file,link)
endef #sm.code.calculate-archive-options

##
define sm.code.calculate-libdirs
 $(foreach sm._var._temp._libdir,$($(strip $1)),\
   $(eval sm.var.$(sm.this.name).link.libs += -L$$(sm._var._temp._libdir:-L%=%)))
endef #sm.code.calculate-libdirs

##
define sm.code.calculate-libs
 $(foreach sm._var._temp._lib,$($(strip $1)),\
   $(eval sm.var.$(sm.this.name).link.libs += -l$$(sm._var._temp._lib:-l%=%)))
endef #sm.code.calculate-libs

##
define sm.code.calculate-link-libs
 sm.var.$(sm.this.name).link.libs :=
 $$(call sm.code.calculate-libdirs,sm.global.libdirs)
 $$(call sm.code.calculate-libdirs,sm.this.libdirs)
 $$(call sm.code.calculate-libs,sm.global.libs)
 $$(call sm.code.calculate-libs,sm.this.libs)
 $(if $(call is-true,$(sm.this.link.options.infile)),\
     $$(call sm-util-mkdir,$(sm.dir.out.tmp)/$(sm.this.name))\
     $$(eval sm.var.$(sm.this.name).link.libs := $$(subst \",\\\",$$(sm.var.$(sm.this.name).link.libs)))\
     $$(shell echo $$(sm.var.$(sm.this.name).link.libs) > $(sm.dir.out.tmp)/$(sm.this.name)/link.libs)\
     $$(eval sm.var.$(sm.this.name).link.libs := @$(sm.dir.out.tmp)/$(sm.this.name)/link.libs))
endef #sm.code.calculate-link-libs

# $(info -----)
# $(info $(call sm.code.calculate-compile-options,c))
# $(info -----)
# $(info $(call sm.code.calculate-link-libs))
# $(info -----)

##########
##
## callbacks for sm.rule.compile.* to get compile options
##
define sm.fun.$(sm.this.name).get-compile-options
 $(if $(sm.var.$(sm.this.name).compile.options.$1),,\
   $(eval $(call sm.code.calculate-compile-options,$1)))\
 $(sm.var.$(sm.this.name).compile.options.$1)
endef #sm.fun.$(sm.this.name).get-compile-options

define sm.fun.$(sm.this.name).get-archive-options
 $(if $(sm.var.$(sm.this.name).archive.options),,\
   $(eval $(call sm.code.calculate-archive-options)))\
 $(sm.var.$(sm.this.name).archive.options)
endef #sm.fun.$(sm.this.name).get-archive-options

define sm.fun.$(sm.this.name).get-link-options
 $(if $(sm.var.$(sm.this.name).link.options),,\
   $(eval $(call sm.code.calculate-link-options)))\
 $(sm.var.$(sm.this.name).link.options)
endef #sm.fun.$(sm.this.name).get-link-options

define sm.fun.$(sm.this.name).get-link-libs
 $(if $(sm.var.$(sm.this.name).link.libs),,\
   $(eval $(call sm.code.calculate-link-libs)))\
 $(sm.var.$(sm.this.name).link.libs)
endef #sm.fun.$(sm.this.name).get-link-libs

$(foreach sm._var._temp._lang,$(sm.tool.$(sm.this.toolset).langs),\
  $(eval sm.fun.$(sm.this.name).get-compile-options.$(sm._var._temp._lang) = $$(strip $$(call sm.fun.$(sm.this.name).get-compile-options,$(sm._var._temp._lang)))))

#$(info c: x$(sm.fun.$(sm.this.name).get-compile-options.c)x)

##################################################

## The output object file prefix
sm._var._temp._object_prefix := \
  $(call sm-to-relative-path,$(sm.dir.out.obj))$(sm.this.dir:$(sm.dir.top)%=%)

##
##
define sm.fun.calculate-object.
$(sm._var._temp._object_prefix)/$(basename $(subst ..,_,$(call sm-to-relative-path,$1))).o
endef #sm.fun.calculate-object.

define sm.fun.calculate-object.external
$(call sm.fun.calculate-object.,$1)
endef #sm.fun.calculate-object.external

##
## source file of relative location
define sm.fun.calculate-source.
$(sm.this.dir)/$(strip $1)
endef #sm.fun.calculate-source.

##
## source file of fixed location
define sm.fun.calculate-source.external
$(strip $1)
endef #sm.fun.calculate-source.external

##
## binary module to be built
define sm.fun.calculate-exe-module-targets
$(call sm-to-relative-path,$(sm.dir.out.bin))/$(sm.this.name)$(sm.this.suffix)
endef #sm.fun.calculate-exe-module-targets

define sm.fun.calculate-shared-module-targets
$(call sm-to-relative-path,$(sm.dir.out.bin))/$(sm.this.name)$(sm.this.suffix)
endef #sm.fun.calculate-shared-module-targets

define sm.fun.calculate-static-module-targets
$(call sm-to-relative-path,$(sm.dir.out.lib))/lib$(sm.this.name:lib%=%)$(sm.this.suffix)
endef #sm.fun.calculate-static-module-targets

##################################################

## Make rule for building object
##   eg. $(call sm.fun.make-object-rule, c++, foobar.cpp)
##   eg. $(call sm.fun.make-object-rule, c++, ~/sources/foobar.cpp, external)
define sm.fun.make-object-rule
 $(if $1,,$(error smart: arg \#1 must be the lang type))\
 $(if $2,,$(error smart: arg \#2 must be the source file))\
 $(eval sm._var._temp._object := $(call sm.fun.calculate-object.$(strip $3),$2))\
 $(eval sm.var.$(sm.this.name).objects += $(sm._var._temp._object))\
 $(call sm.rule.compile.$(strip $1),$(sm._var._temp._object),\
    $(call sm.fun.calculate-source.$(strip $3),$2),\
    sm.fun.$(sm.this.name).get-compile-options.$(strip $1))
endef #sm.fun.make-object-rule

##
## Produce code for make object rules
define sm.code.make-rules
$(if $1,,$(error smart: arg \#1 must be lang-type))\
$(if $(sm.tool.$(sm.this.toolset).$1.suffix),,$(error smart: No registered suffixes for $(sm.this.toolset)/$1))\
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

# $(info $(call sm.code.make-rules,c))
##
## Make object rules, eg. $(call sm.fun.make-rules,c++)
define sm.fun.make-rules
$(eval $(call sm.code.make-rules,$(strip $1)))
endef #sm.fun.make-rules


# TODO: sm.fun.choose-linker, this should be decided by
#       sm.tool.$(sm.this.toolset)
##
## Make a choice in sm.rule.link.c, sm.rule.link.c++, etc.
## Returns the lang-type suffix.
define sm.fun.get-linker
$(warning TODO: choose linker by the toolset)c
endef #sm.fun.get-linker

##
## Make module build rule
define sm.fun.make-module-rule
$(if $(sm.var.$(sm.this.name).objects),\
    $(eval sm.var.$(sm.this.name).targets := $(strip $(call sm.fun.calculate-$(sm.this.type)-module-targets)))\
    $(call sm-check-defined,sm.var.build_action.$(sm.this.type))\
    $(call sm-check-defined,sm.fun.get-linker)\
    $(call sm-check-defined,sm.rule.$(sm.var.build_action.$(sm.this.type)).$(sm.fun.get-linker))\
    $(call sm.rule.$(sm.var.build_action.$(sm.this.type)).$(sm.fun.get-linker),\
       $$(sm.var.$(sm.this.name).targets),\
       $$(sm.var.$(sm.this.name).objects),\
       sm.fun.$(sm.this.name).get-$(sm.var.build_action.$(sm.this.type))-options,\
       sm.fun.$(sm.this.name).get-$(sm.var.build_action.$(sm.this.type))-libs),\
  $(error smart: No objects for building '$(sm.this.name)'))
endef #sm.fun.make-module-rule

##################################################

sm.var.$(sm.this.name).targets :=
sm.var.$(sm.this.name).objects :=

$(foreach sm._var._temp._lang,$(sm.tool.$(sm.this.toolset).langs),\
  $(eval $$(call sm.fun.make-rules,$(sm._var._temp._lang))))

$(call sm.fun.make-module-rule)

ifeq ($(strip $(sm.this.sources.c)$(sm.this.sources.c++)$(sm.this.sources.asm)),)
  $(error smart: internal error: sources mis-calculated)
endif

ifeq ($(strip $(sm.var.$(sm.this.name).targets)),)
  $(error smart: internal error: targets mis-calculated)
endif

ifeq ($(strip $(sm.var.$(sm.this.name).objects)),)
  $(error smart: internal error: objects mis-calculated)
endif

sm.this.targets = $(sm.var.$(sm.this.name).targets)
sm.this.objects = $(sm.var.$(sm.this.name).objects)

##################################################

$(call sm-check-not-empty, sm.tool.common.rm)
$(call sm-check-not-empty, sm.tool.common.rmdir)

sm.rules.phony.* += \
  clean-$(sm.this.name) \
  clean-$(sm.this.name)-target \
  clean-$(sm.this.name)-targets \
  clean-$(sm.this.name)-objects

clean-$(sm.this.name): \
  clean-$(sm.this.name)-targets \
  clean-$(sm.this.name)-objects
	@echo "'$(sm.this.name)' is cleaned."

clean-$(sm.this.name)-target:; $(info smart: do you mean $@s?) @true

clean-$(sm.this.name)-targets:
	$(if $(call is-true,$(sm.this.verbose)),,$(info remove: $(sm.var.$(sm.this.name).targets))@)$(call sm.tool.common.rm,$(sm.var.$(sm.this.name).targets))

clean-$(sm.this.name)-objects:
	$(if $(call is-true,$(sm.this.verbose)),,$(info remove:$(sm.var.$(sm.this.name).objects))@)$(call sm.tool.common.rm,$(sm.var.$(sm.this.name).objects))

##################################################
# $(info objects: $(sm.var.$(sm.this.name).objects))
# $(info c: $(sm.this.sources.c))
# $(info c++: $(sm.this.sources.c++))
