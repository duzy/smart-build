# -*- mode: Makefile:gnu -*-
#	Copyright(c) 2010,2009, by Zhan Xin-ming, duzy@duzy.info
#

## $(call sm.rule.template, ACTION, LANG, TARGET, PREREQUISITES, sources-replacement, callback, callback)
define sm.rule.template
$(if $(sm.this.toolset),,$(error smart: 'sm.this.toolset' must be set for '$2'))\
$(if $(sm.tool.$(sm.this.toolset).$1.$2),,$(error smart: 'sm.tool.$(sm.this.toolset).$1.$2' not set))\
$(call sm-check-flavor,sm.tool.$(sm.this.toolset).$1.$2,recursive,\
   broken toolset '$(sm.this.toolset)': 'sm.tool.$(sm.this.toolset).$1.$2' not recursive)
 $3 : $4
	$$(call sm-util-mkdir,$$(@D))
	$(if $(call equal,$(sm.this.verbose),true),,$(if $(call equal,$1,compile),\
                        $$(info $2: $(sm.this.name) += $(4:$(sm.top)/%=%)),\
                        $$(info $2: $(sm.this.name) -> $3)\
             )@)$$(call sm.tool.$(sm.this.toolset).$1.$2,$$@,$(if $5,$5,$4),$6,$7)
endef #sm.rule.template

## eg. $(call sm.rule, ACTION, LANG, TARGET, PREREQUISITES, callback-FLAGS [,callack-LIBS])
#
define sm.rule
$(if $1,,$(error smart: 'sm.rule': arg 1 must be the action (eg. compile, link)))\
$(if $2,,$(error smart: 'sm.rule': arg 2 must be the language type))\
$(if $3,,$(error smart: 'sm.rule': arg 3 must be the output target))\
$(if $4,,$(error smart: 'sm.rule': arg 4 must be the source file))\
$(if $5,$(if $(call equal,$(5:@%=@),@),,$(error smart: 'sm.rule': arg 5 must be the sources as in '@file')))\
$(if $6,,$(error smart: 'sm.rule': arg 6 must be a callback for command line flags))\
$(if $7,$(call sm-check-defined,$7,smart: 'sm.rule': arg 7 must be a callback for command line flags))\
$(eval $(call sm.rule.template,$(strip $1),$(strip $2),$(strip $3),$(strip $4),$(strip $5),$(strip $6),$(strip $7)))
endef #sm.rule

## eg. $(call sm.rule.dependency, LANG, TARGET, PREREQUISITES, callback-FLAGS)
define sm.rule.dependency
$(if $1,,$(error smart: 'sm.rule.dependency': arg 1 must be the source language))\
$(if $2,,$(error smart: 'sm.rule.dependency': arg 2 must be the dependency file))\
$(if $3,,$(error smart: 'sm.rule.dependency': arg 2 must be the depend target))\
$(if $4,,$(error smart: 'sm.rule.dependency': arg 3 must be the source file))\
$(if $5,$(call sm-check-defined,$5,smart: 'sm.rule.dependency': '$(strip $5)' must be defined as a callback for compile flags))\
$(call sm-check-defined,sm.tool.$(sm.this.toolset).dependency.$(strip $1))\
$(eval \
 $2 : $4
	$$(call sm-util-mkdir,$$(@D))
	$(if $(call equal,$(sm.this.verbose),true),,$$(info $(strip $1): $$@)\
          @)$$(call sm.tool.$(sm.this.toolset).dependency.$(strip $1),$$@,$3,$4,$5)
 )
endef #sm.rule.dependency

## eg. $(call sm.rule.compile, LANG, TARGET, PREREQUISITES, callback-FLAGS)
define sm.rule.compile
$(if $1,,$(error smart: 'sm.rule.compile': arg 1 must be the source language))\
$(if $2,,$(error smart: 'sm.rule.compile': arg 2 must be the output target))\
$(if $3,,$(error smart: 'sm.rule.compile': arg 3 must be the source file))\
$(if $4,$(call sm-check-defined,$4,smart: 'sm.rule.compile': '$(strip $4)' must be defined as a callback for compile flags))\
$(call sm.rule,compile,$(strip $1),$(strip $2),$(strip $3),,$(strip $4))
endef #sm.rule.compile

## eg. $(call sm.rule.link, LANG, TARGET, PREREQUISITES, [@in-file-objects], callback-FLAGS, [,callack-LIBS])
define sm.rule.link
$(if $1,,$(error smart: 'sm.rule.link': arg 1 must be the source language))\
$(if $2,,$(error smart: 'sm.rule.link': arg 2 must be the output target))\
$(if $3,,$(error smart: 'sm.rule.link': arg 3 must be the object files))\
$(if $4,$(if $(call equal,$(4:@%=@),@),,$(error smart: 'sm.rule.link': arg 4 must be objects as '@file')))\
$(if $5,$(call sm-check-defined,$5,smart: 'sm.rule.link': '$5' must be defined as a callback for link flags))\
$(if $6,$(call sm-check-defined,$6,smart: 'sm.rule.link': '$6' must be defined as a callback for libs to be linked))\
$(call sm.rule,link,$(strip $1),$(strip $2),$(strip $3),$(strip $4),$(strip $5),$(strip $6))
endef #sm.rule.link

## eg. $(call sm.rule.archive, LANG, TARGET, PREREQUISITES, [@in-file-objects], callback-FLAGS, [,callack-LIBS])
define sm.rule.archive
$(if $1,,$(error smart: 'sm.rule.archive': arg 1 must be the source language))\
$(if $2,,$(error smart: 'sm.rule.archive': arg 2 must be the output target))\
$(if $3,,$(error smart: 'sm.rule.archive': arg 3 must be the objects to be archive))\
$(if $4,$(if $(call equal,$(4:@%=@),@),,$(error smart: 'sm.rule.archive': arg 4 must be objects as '@file')))\
$(if $5,$(call sm-check-defined,$5,smart: 'sm.rule.archive': '$5' must be defined as a callback for archive flags))\
$(call sm.rule,archive,$(strip $1),$(strip $2),$(strip $3),$(strip $4),$(strip $5))
endef #sm.rule.archive

