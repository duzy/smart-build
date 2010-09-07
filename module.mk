#

$(call sm-check-not-empty,sm.top)
$(call sm-check-not-empty,sm.this.toolset,smart: Must set 'sm.this.toolset')

ifeq ($(strip $(sm.this.sources)$(sm.this.sources.external)),)
  $(error smart: No sources for module '$(sm.this.name)')
endif

##################################################

# TODO: support sm.this.compile.options.infile
# TODO: 

sm.var.$(sm.this.name).compile.options. :=
sm.var.$(sm.this.name).compile.options.c :=
sm.var.$(sm.this.name).compile.options.c++ :=
sm.var.$(sm.this.name).compile.options.asm :=
sm.var.$(sm.this.name).link.options :=
sm.var.$(sm.this.name).link.libs :=

##
define sm.code.calculate-includes
 $(foreach sm._var._temp._include,$($(strip $2)),\
   $(eval sm.var.$(sm.this.name).compile.options.$(strip $1) += -I$$(sm._var._temp._include:-I%=%)))
endef #sm.code.calculate-includes

##
define sm.code.calculate-compile-options
 sm.var.$(sm.this.name).compile.options.$1 := \
  $(strip $(sm.global.compile.flags) $(sm.global.compile.options)) \
  $(strip $(sm.global.compile.flags.$1) $(sm.global.compile.options.$1)) \
  $(strip $(sm.this.compile.flags) $(sm.this.compile.options)) \
  $(strip $(sm.this.compile.flags.$1) $(sm.this.compile.options.$1))
 $$(call sm.code.calculate-includes,$1,sm.global.includes)
 $$(call sm.code.calculate-includes,$1,sm.this.includes)
endef #sm.code.calculate-compile-options

##
define sm.code.calculate-link-options
 sm.var.$(sm.this.name).link.options := \
  $(strip $(sm.global.link.flags) $(sm.global.link.options)) \
  $(strip $(sm.this.link.flags) $(sm.this.link.options))
endef #sm.code.calculate-link-options

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

define sm.fun.$(sm.this.name).get-link-options.any
 $(if $(sm.var.$(sm.this.name).link.options),,\
   $(eval $(call sm.code.calculate-link-options)))\
 $(sm.var.$(sm.this.name).link.options)
endef #sm.fun.$(sm.this.name).get-link-options.any

define sm.fun.$(sm.this.name).get-link-libs.any
 $(if $(sm.var.$(sm.this.name).link.libs),,\
   $(eval $(call sm.code.calculate-link-libs)))\
 $(sm.var.$(sm.this.name).link.libs)
endef #sm.fun.$(sm.this.name).get-link-libs.any

$(foreach sm._var._temp._lang,$(sm.tool.$(sm.this.toolset).langs),\
  $(eval sm.fun.$(sm.this.name).get-compile-options.$(sm._var._temp._lang) = $$(strip $$(call sm.fun.$(sm.this.name).get-compile-options,$(sm._var._temp._lang)))))

sm.fun.$(sm.this.name).get-link-options = $(strip $(call sm.fun.$(sm.this.name).get-link-options.any))
sm.fun.$(sm.this.name).get-link-libs = $(strip $(call sm.fun.$(sm.this.name).get-link-libs.any))

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
define sm.fun.calculate-module.bin
$(call sm-to-relative-path,$(sm.dir.out.bin))/$(sm.this.name)$(sm.this.suffix)
endef #sm.fun.calculate-module.bin

##
## library module to be built
#define sm.fun.calculate-module.lib
#$(call sm-to-relative-path,$(sm.dir.out.lib))/$(sm.this.name)$(sm.this.suffix)
#endef #sm.fun.calculate-module.lib

##################################################

## Make rule for building object
##   eg. $(call sm.fun.make-object-rule, c++, foobar.cpp)
##   eg. $(call sm.fun.make-object-rule, c++, ~/sources/foobar.cpp, external)
define sm.fun.make-object-rule
 $(if $1,,$(error smart: arg \#1 must be the lang type))\
 $(if $2,,$(error smart: arg \#2 must be the source file))\
 $(eval sm._var._temp._object := $(call sm.fun.calculate-object.$(strip $3),$2))\
 $(eval sm.this.objects += $(sm._var._temp._object))\
 $(call sm.rule.compile.$(strip $1),$(sm._var._temp._object),\
    $(call sm.fun.calculate-source.$(strip $3),$2),\
    sm.fun.$(sm.this.name).get-compile-options.$(strip $1))
endef #sm.fun.make-object-rule

##
## Produce code for make object rules
define sm.code.make-rules
 $(if $(sm.tool.$(sm.this.toolset).$1.suffix),,$(error smart: No registered suffixes for $(sm.this.toolset)/$1))
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
define sm.fun.choose-linker
.c
endef #sm.fun.choose-linker

##
## Make module build rule
define sm.fun.make-module-rule
$(if $(sm.this.objects),\
    $(call sm.rule.link$(call sm.fun.choose-linker),\
       $(call sm.fun.calculate-module.bin) $(call sm.fun.calculate-module.lib),\
       $(sm.this.objects), sm.fun.$(sm.this.name).get-link-options,\
       sm.fun.$(sm.this.name).get-link-libs),\
  $(error smart: No objects for building '$(sm.this.name)'))
endef #sm.fun.make-module-rule

##################################################

$(foreach sm._var._temp._lang,$(sm.tool.$(sm.this.toolset).langs),\
  $(eval $$(call sm.fun.make-rules,$(sm._var._temp._lang))))

$(call sm.fun.make-module-rule)

ifeq ($(strip $(sm.this.sources.c)$(sm.this.sources.c++)$(sm.this.sources.asm)),)
  $(error smart: internal error: sources mis-calculated)
endif

ifeq ($(strip $(sm.this.objects)),)
  $(error smart: internal error: objects mis-calculated)
endif

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
	$(call sm.tool.common.rm,$(sm.this.targets))

clean-$(sm.this.name)-objects:
	$(call sm.tool.common.rm,$(sm.this.objects))

##################################################
# $(info objects: $(sm.this.objects))
# $(info c: $(sm.this.sources.c))
# $(info c++: $(sm.this.sources.c++))
