# -*- mode: Makefile:gnu -*-
#	Copyright(c) 2010,2009, by Zhan Xin-ming, duzy@duzy.info
#

## $(call sm.rule.template, ACTION, LANG, TARGET, PREREQUISITES)
define sm.rule.template
$(if $(sm.toolset),,$(error smart: toolset unset))
$(if $(sm.tool.$(sm.toolset).$(strip $1).$(strip $2)),,\
    $(error smart: 'sm.tool.$(sm.toolset).$(strip $1).$(strip $2)' not set))
$(strip $3) : $(strip $4)
	$$(call sm.tool.$(sm.toolset).$(strip $1).$(strip $2),$$@,$$^)
endef

## $(call sm.rule, ACTION, LANG, TARGET, PREREQUISITES)
define sm.rule
$(if $1,,$(error smart: arg \#1 must be the action (eg. compile, link)))\
$(if $2,,$(error smart: arg \#1 must be the source language))\
$(if $3,,$(error smart: arg \#1 must be the output target))\
$(if $4,,$(error smart: arg \#2 must be the source file))\
$(eval $(call sm.rule.template,$1,$2,$3,$4))
endef

sm.rule.compile     = $(call sm.rule,compile,$1,$2,$3)
sm.rule.compile.c   = $(call sm.rule,compile,c,$1,$2)
sm.rule.compile.c++ = $(call sm.rule,compile,c++,$1,$2)
sm.rule.compile.asm = $(call sm.rule,compile,asm,$1,$2)

sm.rule.link     = $(call sm.rule,link,$1,$2,$3)
sm.rule.link.c   = $(call sm.rule,link,c,$1,$2)
sm.rule.link.c++ = $(call sm.rule,link,c++,$1,$2)
sm.rule.link.asm = $(call sm.rule,link,asm,$1,$2)
