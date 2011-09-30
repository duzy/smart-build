# -*- mode: Makefile:gnu -*-
#	Copyright(c) 2010,2009, by Zhan Xin-ming, duzy@duzy.info
#

define sm-rule
$(call sm-check-flavor,\
   $(sm.var.toolset).$(sm.args.action).$(sm.args.lang),recursive,\
   broken toolset '$(sm.this.toolset)': '$(sm.var.toolset).$(sm.args.action).$(sm.args.lang)' is not recursive)\
$(eval \
  ifeq ($(sm.global.has.rule.$(sm.args.target)),)
   sm.global.has.rule.$(sm.args.target) := true
   $(sm.args.target) : $(sm.args.prerequisites)
	$$(call sm-util-mkdir,$$(@D))
	$(if $(call equal,$(sm.this.verbose),true),,\
             $(if $(call equal,$(sm.args.action),compile),\
                  $$(info $(sm.args.lang): $(sm.this.name) += $(sm.args.sources:$(sm.top)/%=%)),\
                  $$(info $(sm.args.lang): $(sm.this.name) -> $(sm.args.target))\
             )$(sm.var.Q)\
        )$($(sm.var.toolset).$(sm.args.action).$(sm.args.lang))
  else
   #$$(info smart: rule duplicated for $(sm.args.target))
  endif
  )
endef #sm-rule

sm-rule-compile = $(eval sm.args.action := compile)$(call sm-rule)
sm-rule-link    = $(eval sm.args.action := link)$(call sm-rule)
sm-rule-archive = $(eval sm.args.action := archive)$(call sm-rule)

sm-rule-dependency = $(error smart: internal: sm-rule-dependency is deprecated)
