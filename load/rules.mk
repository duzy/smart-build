# -*- mode: Makefile:gnu -*-
#	Copyright(c) 2010,2009, by Zhan Xin-ming, duzy@duzy.info
#

sm.var.target_type.static := static-library
sm.var.target_type.shared := shared-library
sm.var.target_type.exe := executable
sm.var.target_type.t := test
define sm.fun.get-target-type
$(strip $(or $(sm.var.target_type.$($(sm._this).type)),$($(sm._this).type)))
endef #sm.fun.get-target-type

define sm-rule
$(call sm-check-flavor,\
   $(sm.var.toolset).$(sm.args.action).$(sm.args.lang),recursive,\
   broken toolset '$($(sm._this).toolset)': '$(sm.var.toolset).$(sm.args.action).$(sm.args.lang)' is not recursive)\
$(eval \
  ifeq ($(sm._this),)
    $$(error smart: internal: sm._this is empty)
  endif

  ifeq ($(sm.global.has.rule.$(sm.args.target)),)
   sm.global.has.rule.$(sm.args.target) := true
   $(sm.args.target) : $(sm.args.prerequisites)
	$$(call sm-util-mkdir,$$(@D))
    ifeq ($(call is-true,$($(sm._this).verbose)),true)
	$($(sm.var.toolset).$(sm.args.action).$(sm.args.lang))
    else
      ifeq ($(sm.args.action),compile)
	$$(info $(sm.args.lang): $($(sm._this).name) += $(sm.args.sources:$(sm.top)/%=%))
      else
	$$(info $(sm.fun.get-target-type): $($(sm._this).name) -> $(sm.args.target))
      endif
	$(sm.var.Q)$(filter %, $($(sm.var.toolset).$(sm.args.action).$(sm.args.lang)))
    endif
  endif
  )
endef #sm-rule

sm-rule-compile = $(eval sm.args.action := compile)$(call sm-rule)
sm-rule-link    = $(eval sm.args.action := link)$(call sm-rule)
sm-rule-archive = $(eval sm.args.action := archive)$(call sm-rule)

sm-rule-dependency = $(error smart: internal: sm-rule-dependency is deprecated)
