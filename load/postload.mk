# -*- mode: Makefile:gnu -*-
#	Copyright(c) 2009, by Zhan Xin-ming, duzy@duzy.info
#	

## This file is expected to be included AFTER including an 'smart.mk'(module).

$(foreach sm.var.temp._lang,$(sm.var.common.langs.extra),\
   $(eval sm.this.sources.$(sm.var.temp._lang) :=)\
   $(eval sm.this.sources.has.$(sm.var.temp._lang) :=))
