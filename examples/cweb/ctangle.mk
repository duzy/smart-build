#

$(call sm-new-module, ctangle, exe, gcc)

sm.this.verbose := false
sm.this.lang := c
sm.this.sources := ctangle.w common.w cwebman.tex

$(sm-build-this)

# $(info ctangle: $(sm.var.ctangle.sources.common))
# $(info ctangle: $(sm.var.ctangle.sources.c))
#$(info ctangle: $(sm.var.ctangle.sources.TeX))
# $(info ctangle: $(sm.this.sources.common))
# $(info ctangle: $(sm.this.sources.c))
#$(info ctangle: $(sm.this.sources.TeX))
# $(info ctangle: $(sm.this.intermediates))

prefix := $(sm.out.inter)/common
$(call sm-check-equal,$(strip $(sm.var.ctangle.sources.c)),$(prefix)/ctangle.c $(prefix)/common.c)
$(call sm-check-equal,$(strip $(sm.var.ctangle.sources.TeX)),cwebman.tex $(prefix)/ctangle.tex $(prefix)/common.tex)
$(call sm-check-equal,$(strip $(sm.this.sources.c)),$(prefix)/ctangle.c $(prefix)/common.c)
$(call sm-check-equal,$(strip $(sm.this.sources.TeX)),cwebman.tex $(prefix)/ctangle.tex $(prefix)/common.tex)
$(call sm-check-equal,$(strip $(sm.this.intermediates)),$(sm.out.inter)/$(prefix)/ctangle.o $(sm.out.inter)/$(prefix)/common.o)
