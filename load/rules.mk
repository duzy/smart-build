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
$(sm._this).prefix := $(sm.var.temp._)

sm.var.action := $(sm.var.action.$($(sm._this).type))
$(call sm-check-not-empty, sm.var.action)

sm.var._headers_vars := $(filter $(sm._this).headers.%,$(.VARIABLES))
sm.var._headers_vars := $(filter-out \
    %.headers.* \
    %.headers.??? \
   ,$(sm.var._headers_vars))

sm.args.docs_format := ${strip $($(sm._this).docs.format)}
ifndef sm.args.docs_format
  sm.args.docs_format := .dvi
endif

## We copy the public headers first, since the module itself may make use on
## the headers.
ifneq ($($(sm._this)._intermediates_only),true)
  $(call sm.fun.copy-headers)
endif

## Store the unterminated intermediates, all terminated intermediates are stored
## in $(sm._this).intermediates, and the final module targets produced from it.
##
## Note that $(sm._this).intermediates may be initialized with something by the
## module smart.mk scripts, and should not be reset.
$(sm._this).unterminated          :=
$(sm._this).unterminated.external :=

## The strange unterminated intermediates is unexpected errors, should be
## reported to users.
$(sm._this).unterminated.strange  :=

## Firstly, we compute the using list.
$(call sm.fun.compute-using-list)

## And toolset must be initialized.
ifneq ($(strip $($(sm._this).type)),depends)
  $(call sm.fun.init-toolset)
endif ## $(sm._this).type != depends

## Computes the terminated intermediates.
$(call sm.fun.compute-terminated-intermediates)
$(warning intermediates:$($(sm._this).intermediates))

sm.var.temp._should_make_targets := \
  $(if $(or $(call not-equal,$(strip $($(sm._this).sources.unknown)),),\
            $(call equal,$(strip $($(sm._this).toolset)),common),\
            $(call equal,$(strip $($(sm._this).type)),depends),\
            $(call equal,$(strip $($(sm._this).intermediates)),),\
            $(call is-true,$($(sm._this)._intermediates_only))),\
   ,true)
#ifeq ($(sm.var.temp._should_make_targets),true)
  $(call sm.fun.make-module-targets)
  $(warning $($(sm._this).name): $($(sm._this).targets))
#endif #$(sm.var.temp._should_make_targets) == true

ifneq ($($(sm._this)._intermediates_only),true)
  $(call sm.fun.make-goal-rules)
  $(call sm.fun.make-test-rules)
  $(call sm.fun.make-clean-rules)
  $(call sm.fun.invoke-toolset-built-target-mk)
endif
