# -*- mode: Makefile:gnu -*-
#	Copyright(c) 2010,2009, by Zhan Xin-ming, duzy@duzy.info
#

define sm-rule
$(call sm-check-flavor,\
   sm.tool.$(sm.this.toolset).$(sm.args.action).$(sm.args.lang),recursive,\
   broken toolset '$(sm.this.toolset)': 'sm.tool.$(sm.this.toolset).$(sm.args.action).$(sm.args.lang)' is not recursive)\
$(eval $(sm.args.target) : $(sm.args.sources)
	$$(call sm-util-mkdir,$$(@D))
	$(if $(call equal,$(sm.this.verbose),true),,\
             $(if $(call equal,$(sm.args.action),compile),\
                  $$(info $(sm.args.lang): $(sm.this.name) += $(sm.args.sources:$(sm.top)/%=%)),\
                  $$(info $(sm.args.lang): $(sm.this.name) -> $(sm.args.target))\
             )$(sm.var.Q)\
        )$(sm.tool.$(sm.this.toolset).$(sm.args.action).$(sm.args.lang)))
endef #sm-rule

define sm-rule-dependency
$(eval $(sm.args.output) : $(sm.args.sources)
	$$(call sm-util-mkdir,$$(@D))
	$(if $(call equal,$(sm.this.verbose),true),,\
          $$(info smart: update $(sm.args.output))\
        $(sm.var.Q))$(sm.tool.$(sm.this.toolset).dependency.$(sm.args.lang)))
endef #sm-rule-dependency

sm-rule-compile = $(eval sm.args.action := compile)$(call sm-rule)
sm-rule-link    = $(eval sm.args.action := link)$(call sm-rule)
sm-rule-archive = $(eval sm.args.action := archive)$(call sm-rule)
