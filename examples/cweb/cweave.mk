#

$(call sm-new-module, cweave, exe, gcc)

sm.this.verbose := false
sm.this.lang := c
sm.this.sources := cweave.w common.w prod.w

$(sm-build-this)

prefix := $(sm.out.inter)/common
$(call sm-check-equal,$(strip $(sm.this.intermediates)),$(sm.out.inter)/$(prefix)/cweave.o $(sm.out.inter)/$(prefix)/common.o $(sm.out.inter)/$(prefix)/prod.o)
$(call sm-check-equal,$(sm.this.intermediates),$(sm.this.inters))
$(call sm-check-equal,$(strip $(sm.this.sources.c)),$(prefix)/cweave.c $(prefix)/common.c $(prefix)/prod.c)
$(call sm-check-equal,$(strip $(sm.var.cweave.sources.c)),$(prefix)/cweave.c $(prefix)/common.c $(prefix)/prod.c)