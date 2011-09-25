#

$(call sm-new-module, ctangle, exe, gcc)

sm.this.verbose := false
sm.this.lang := c
sm.this.sources := ctangle.w common.w 
#cwebman.tex

$(sm-build-this)

# $(info ctangle: $(sm.var.ctangle.sources.common))
# $(info ctangle: $(sm.var.ctangle.sources.c))
#$(info ctangle: $(sm.var.ctangle.sources.TeX))
# $(info ctangle: $(sm.this.sources.common))
# $(info ctangle: $(sm.this.sources.c))
#$(info ctangle: $(sm.this.sources.TeX))
# $(info ctangle: $(sm.this.objects))

$(call sm-check-equal,$(strip $(sm.var.ctangle.sources.c)),$(sm.out.inter)/ctangle.c $(sm.out.inter)/common.c)
#$(call sm-check-equal,$(strip $(sm.var.ctangle.sources.TeX)),$(sm.out.inter)/ctangle.c $(sm.out.inter)/common.c)
$(call sm-check-equal,$(strip $(sm.this.sources.c)),$(sm.out.inter)/ctangle.c $(sm.out.inter)/common.c)
#$(call sm-check-equal,$(strip $(sm.this.sources.TeX)),cwebman.tex $(sm.out.inter)/ctangle.tex $(sm.out.inter)/common.tex)
$(call sm-check-equal,$(strip $(sm.this.objects)),$(sm.out.obj)/$(sm.out.inter)/ctangle.o $(sm.out.obj)/$(sm.out.inter)/common.o)
