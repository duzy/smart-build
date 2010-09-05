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
	$$(call sm.tool.$(sm.this.toolset).$1.$2,$$@,$$^,$5,$6)
endef #sm.rule.template

## $(call sm.rule, ACTION, LANG, TARGET, PREREQUISITES, callback-FLAGS, callack-LIBS)
define sm.rule
$(if $1,,$(error smart: arg \#1 must be the action (eg. compile, link)))\
$(if $2,,$(error smart: arg \#2 must be the source language))\
$(if $3,,$(error smart: arg \#3 must be the output target))\
$(if $4,,$(error smart: arg \#4 must be the source file))\
$(if $5,,$(error smart: arg \#5 must be a callback for command line flags))\
$(eval $(call sm.rule.template,$(strip $1),$(strip $2),$(strip $3),$(strip $4),$(strip $5),$(strip $6)))
endef #sm.rule

sm.rule.compile     = $(call sm.rule,compile,$1,$2,$3,$4)
sm.rule.compile.c   = $(call sm.rule,compile,c,$1,$2,$3)
sm.rule.compile.c++ = $(call sm.rule,compile,c++,$1,$2,$3)
sm.rule.compile.asm = $(call sm.rule,compile,asm,$1,$2,$3)

sm.rule.link     = $(call sm.rule,link,$1,$2,$3,$4,$5)
sm.rule.link.c   = $(call sm.rule,link,c,$1,$2,$3,$4)
sm.rule.link.c++ = $(call sm.rule,link,c++,$1,$2,$3,$4)
sm.rule.link.asm = $(call sm.rule,link,asm,$1,$2,$3,$4)
