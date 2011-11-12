#
$(call sm-new-module, toolset-common-cweave, exe, gcc)

sm.this.lang := c
sm.this.langs := c TeX
sm.this.sources := cweave.w common.w prod.w

$(sm-build-this)

# prefix := $(sm.out.inter)/common
# $(call sm-check-equal,$(sm.module.cweave.name),cweave)
# $(call sm-check-equal,$(sm.module.cweave.sources.unknown),)
# $(call sm-check-equal,$(sm.module.cweave.sources.common),cweave.w common.w prod.w)
# $(call sm-check-equal,$(sm.module.cweave.sources.c),$(prefix)/cweave.c $(prefix)/common.c $(prefix)/prod.c)
# $(call sm-check-equal,$(sm.module.cweave.sources.TeX),$(prefix)/cweave.tex $(prefix)/common.tex $(prefix)/prod.tex)
# $(call sm-check-equal,$(sm.module.cweave.sources.has.c),true)
# $(call sm-check-equal,$(sm.module.cweave.sources.has.TeX),true)
# $(call sm-check-equal,$(sm.module.cweave.intermediates),$(sm.out.inter)/$(prefix)/cweave.o $(sm.out.inter)/$(prefix)/common.o $(sm.out.inter)/$(prefix)/prod.o)
# $(call sm-check-equal,$(sm.module.cweave.targets),$(sm.out.bin)/cweave)
# $(call sm-check-equal,$(sm.this.intermediates),$(sm.out.inter)/$(prefix)/cweave.o $(sm.out.inter)/$(prefix)/common.o $(sm.out.inter)/$(prefix)/prod.o)
# $(call sm-check-equal,$(sm.this.intermediates),$(sm.this.inters))
# $(call sm-check-equal,$(sm.this.sources.c),$(prefix)/cweave.c $(prefix)/common.c $(prefix)/prod.c)
# $(call sm-check-equal,$(sm.this.sources.TeX),$(prefix)/cweave.tex $(prefix)/common.tex $(prefix)/prod.tex)
