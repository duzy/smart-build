# -*- mode: Makefile:gnu -*-
#	Copyright(c) 2009, by Zhan Xin-ming, duzy@duzy.info
#

## This file is expected to be included BEFORE including an 'smart.mk'(module).

sm.log.filename :=
sm.this.clean-steps :=
sm.this.compile.flags :=
sm.this.compile.flags.infile :=
sm.this.depends :=
sm.this.depends.copyfiles :=
sm.this.dir :=
sm.this.docs.format := .dvi
sm.this.gen_deps := true
sm.this.headers :=
sm.this.includes :=
sm.this.intermediates :=
sm.this.intermediates.defined :=
sm.this.lang :=
sm.this.libdirs :=
sm.this.libs :=
sm.this.link.flags :=
sm.this.link.flags.infile :=
sm.this.name :=
sm.this.out_implib :=
sm.this.rpath :=
sm.this.rpath-link :=
sm.this.sources :=
sm.this.sources.common :=
sm.this.sources.generated :=
sm.this.suffix :=
sm.this.targets :=
sm.this.toolset :=
sm.this.type :=
sm.this.using :=
sm.this.whole_archives :=

$(foreach sm.var.temp._lang,$(sm.tool.common.langs),\
   $(eval sm.this.sources.$(sm.var.temp._lang) :=)\
   $(eval sm.this.sources.has.$(sm.var.temp._lang) :=))
