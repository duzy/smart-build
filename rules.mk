# -*- mode: Makefile:gnu -*-
#	Copyright(c) 2010,2009, by Zhan Xin-ming, duzy@duzy.info
#

## $(call sm.rule.template, ACTION, LANG, TARGET, PREREQUISITES)
define sm.rule.template
$(if $(sm.this.toolset),,$(error smart: 'sm.this.toolset' must be set for '$2'))\
$(if $(sm.tool.$(sm.this.toolset).$1.$2),,$(error smart: 'sm.tool.$(sm.this.toolset).$1.$2' not set))\
$(call sm-check-flavor,sm.tool.$(sm.this.toolset).$1.$2,recursive,\
   Broken toolset '$(sm.this.toolset)': 'sm.tool.$(sm.this.toolset).$1.$2' not recursive)
 $3 : $4
	$$(call sm-util-mkdir,$$(@D))
	$(if $(call equal,$(sm.this.verbose),true),,$(if $(call equal,$1,compile),\
                        $$(info $2: $(sm.this.name) += $(4:$(sm.top)/%=%)),\
                        $$(info $2: $(sm.this.name) -> $3)\
             )@)$$(call sm.tool.$(sm.this.toolset).$1.$2,$$@,$$^,$5,$6)
endef #sm.rule.template

## eg. $(call sm.rule, ACTION, LANG, TARGET, PREREQUISITES, callback-FLAGS [,callack-LIBS])
define sm.rule
$(if $1,,$(error smart: arg \#1 must be the action (eg. compile, link)))\
$(if $2,,$(error smart: arg \#2 must be the source language))\
$(if $3,,$(error smart: arg \#3 must be the output target))\
$(if $4,,$(error smart: arg \#4 must be the source file))\
$(if $5,,$(error smart: arg \#5 must be a callback for command line flags))\
$(eval $(call sm.rule.template,$(strip $1),$(strip $2),$(strip $3),$(strip $4),$(strip $5),$(strip $6)))
endef #sm.rule

## eg. $(call sm.rule.compile, LANG, TARGET, PREREQUISITES, callback-FLAGS)
define sm.rule.compile
$(if $1,,$(error smart: arg \#1 must be the source language))\
$(if $2,,$(error smart: arg \#2 must be the output target))\
$(if $3,,$(error smart: arg \#3 must be the source file))\
$(if $4,$(call sm-check-defined,$(strip $4),smart: '$(strip $4)' must be defined as a callback for compile flags))\
$(call sm.rule,compile,$(strip $1),$(strip $2),$(strip $3),$(strip $4))
endef #sm.rule.compile

## eg. $(call sm.rule.link, LANG, TARGET, PREREQUISITES, callback-FLAGS, [,callack-LIBS])
define sm.rule.link
$(if $1,,$(error smart: arg \#1 must be the source language))\
$(if $2,,$(error smart: arg \#2 must be the output target))\
$(if $3,,$(error smart: arg \#3 must be the source file))\
$(if $4,$(call sm-check-defined,$(strip $4),smart: '$(strip $4)' must be defined as a callback for link flags))\
$(if $5,$(call sm-check-defined,$(strip $5),smart: '$(strip $5)' must be defined as a callback for libs to be linked))\
$(call sm.rule,link,$(strip $1),$(strip $2),$(strip $3),$(strip $4),$(strip $5))
endef #sm.rule.link

# ## FIXME: at this time $(sm.this.toolset) is empty, ...
# $(foreach sm._var._temp._lang,$(sm.tool.$(sm.this.toolset).langs),\
#   $(eval sm.rule.compile.$(sm._var._temp._lang) = $$(call sm.rule,compile,$(sm._var._temp._lang),$$1,$$2,$$3))\
#   $(eval sm.rule.link.$(sm._var._temp._lang) = $$(call sm.rule,link,$(sm._var._temp._lang),$$1,$$2,$$3,$$4)))
