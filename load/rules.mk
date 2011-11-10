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

ifndef sm._this
  $(error sm._this is empty)
endif # sm._this == ""

$(call sm-check-not-empty,	\
    $(sm._this).dir		\
    $(sm._this).name		\
    $(sm._this).type		\
 )

##################################################

## configure the module if not yet done
$(sm._this)._configured := true
$(sm._this).out.tmp := $(sm.out.tmp)/$($(sm._this).name)
$(sm._this).user_defined_targets := $($(sm._this).targets)
$(sm._this).targets :=

## get toolset name
sm.var.tool := sm.tool.$($(sm._this).toolset)
sm.var.langs := $($(sm.var.tool).langs)

sm.var.temp._ := $($(sm._this).dir:$(sm.top)%=%)
sm.var.temp._ := $(sm.var.temp._:%.=%)
sm.var.temp._ := $(sm.var.temp._:/%=%)
sm.var.temp._ := ${if $(sm.var.temp._),$(sm.var.temp._)/}
$(sm._this)._intermediate_prefix := $(sm.var.temp._)

## Compute sources of each language supported by the toolset.
$(call sm.fun.compute-sources)
$(call sm.fun.compute-using-list)
#$(call sm.fun.compute-using)

##################################################

sm.var.action.static := archive
sm.var.action.shared := link
sm.var.action.exe := link
sm.var.action.t := link
sm.var.action := $(sm.var.action.$($(sm._this).type))

ifneq ($(strip $($(sm._this).type)),depends)
  $(call sm.fun.init-toolset)
endif ## $(sm._this).type != depends

sm.var._headers_vars := $(filter $(sm._this).headers.%,$(.VARIABLES))
sm.var._headers_vars := $(filter-out \
    %.headers.* \
    %.headers.??? \
   ,$(sm.var._headers_vars))

## This is a second check, the first check is done in sm-build-this.
ifeq (${strip \
         $(foreach _,$(sm.var._headers_vars),$($_))\
         $($(sm._this).headers)\
         $($(sm._this).sources)\
         $($(sm._this).sources.external)\
         $($(sm._this).depends)\
         $($(sm._this).depends.copyfiles)\
         $($(sm._this).intermediates)},)
  $(error smart: no sources or intermediates or depends for module '$($(sm._this).name)')
endif

ifeq ($($(sm._this).type),t)
  ifndef $(sm._this).lang
    $(error '$(sm._this).lang' must be defined for "tests" module)
  endif
endif

sm.args.docs_format := ${strip $($(sm._this).docs.format)}
ifndef sm.args.docs_format
  sm.args.docs_format := .dvi
endif

##################################################

## Clear compile options for all langs
ifneq ($(strip $($(sm._this).type)),depends)
${foreach sm.var.lang,$(sm.var.langs),\
  ${eval $(sm._this).compile.flags.$($(sm._this)._cnum).$(sm.var.lang) := }\
  ${eval $(sm._this).compile.flags.$($(sm._this)._cnum).$(sm.var.lang).computed := }}
endif ## $(sm._this).type != depends

$(sm._this)._link.flags :=
$(sm._this)._link.flags.computed :=
$(sm._this)._link.intermediates =
$(sm._this)._link.intermediates.computed :=
$(sm._this)._link.libs :=
$(sm._this)._link.libs.computed :=

$(sm._this).flag_files :=

##################################################

## Check strange sources and compute common sources.
sm.var.langs.common :=
sm.var.langs.common.extra :=
$(sm._this).sources.common :=
$(sm._this).sources.unknown :=
ifneq ($(strip $($(sm._this).type)),depends)
  $(foreach sm.var.source, \
      $($(sm._this).sources) \
      $($(sm._this).sources.external) \
   ,\
      $(sm.fun.check-strange-and-compute-common-source) \
   )
endif ## $(sm._this).type != depends

## Export computed common sources of different language and make compile rules
## for common sources(files not handled by the toolset, e.g. .w, .nw, etc).
$(call sm.fun.make-common-compile-rules-for-langs,\
    $(sm.var.langs.common) \
    $(sm.var.langs.common.extra) \
 )

ifneq ($($(sm._this).type),depends)
  $(call sm.fun.make-compile-rules-for-langs)
endif ## $(sm._this).type != depends

ifeq ($($(sm._this).type),t)
  $(call sm.fun.make-t-compile-rules-for-langs)
endif # $(sm._this).type == t

sm.var.temp._should_make_targets := \
  $(if $(or $(call not-equal,$(strip $($(sm._this).sources.unknown)),),\
            $(call equal,$(strip $($(sm._this).type)),depends),\
            $(call equal,$(strip $($(sm._this).intermediates)),),\
            $(call is-true,$($(sm._this)._intermediates_only)))\
        ,,true)

## make module targets
ifneq ($($(sm._this).toolset),common)
  ifeq ($(sm.var.temp._should_make_targets),true)
    $(call sm.fun.make-module-targets)
  endif #$(sm.var.temp._should_make_targets) == true
endif #$($(sm._this).toolset) != common

##################################################

$(sm._this).module_targets := $($(sm._this).targets)
$(sm._this).targets += $($(sm._this).user_defined_targets)
$(sm._this).inters = $($(sm._this).intermediates)

ifneq ($($(sm._this)._intermediates_only),true)
  $(call sm.fun.copy-headers)
  $(call sm.fun.make-goal-rules)
  $(call sm.fun.make-test-rules)
  $(call sm.fun.make-clean-rules)
  $(call sm.fun.invoke-toolset-built-target-mk)
endif

##################################################
