#

$(call sm-new-module, cweave, exe, gcc)

sm.this.verbose := false
sm.this.lang := c
sm.this.sources := cweave.w common.w prod.w

$(sm-build-this)

$(call sm-check-equal,$(strip $(sm.this.objects)),$(sm.out.obj)/$(sm.out.inter)/cweave.o $(sm.out.obj)/$(sm.out.inter)/common.o $(sm.out.obj)/$(sm.out.inter)/prod.o)
$(call sm-check-equal,$(strip $(sm.this.sources.c)),$(sm.out.inter)/cweave.c $(sm.out.inter)/common.c $(sm.out.inter)/prod.c)
$(call sm-check-equal,$(strip $(sm.var.cweave.sources.c)),$(sm.out.inter)/cweave.c $(sm.out.inter)/common.c $(sm.out.inter)/prod.c)
