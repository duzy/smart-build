#

$(call sm-new-module, ctangle, exe, gcc)

sm.this.verbose := false
sm.this.lang := c
sm.this.sources := ctangle.w common.w cwebman.tex

$(sm-build-this)

# $(info ctangle: $(sm.module.ctangle.sources.common))
# $(info ctangle: $(sm.module.ctangle.sources.c))
#$(info ctangle: $(sm.module.ctangle.sources.TeX))
# $(info ctangle: $(sm.this.sources.common))
# $(info ctangle: $(sm.this.sources.c))
#$(info ctangle: $(sm.this.sources.TeX))
# $(info ctangle: $(sm.this.intermediates))

prefix := $(sm.out.inter)/common
$(call sm-check-equal,$(sm.module.ctangle.sources.unknown),)
$(call sm-check-equal,$(sm.module.ctangle.sources.common),ctangle.w common.w cwebman.tex)
$(call sm-check-equal,$(sm.module.ctangle.sources.c),$(prefix)/ctangle.c $(prefix)/common.c)
$(call sm-check-equal,$(sm.module.ctangle.sources.TeX),cwebman.tex $(prefix)/ctangle.tex $(prefix)/common.tex)
$(call sm-check-equal,$(sm.module.ctangle.sources.has.c),true)
$(call sm-check-equal,$(sm.module.ctangle.sources.has.TeX),true)
$(call sm-check-equal,$(sm.module.ctangle.intermediates),$(sm.out.inter)/$(prefix)/ctangle.o $(sm.out.inter)/$(prefix)/common.o)
$(call sm-check-equal,$(sm.module.ctangle.targets),$(sm.out.bin)/ctangle)
$(call sm-check-equal,$(sm.this.sources.c),$(prefix)/ctangle.c $(prefix)/common.c)
$(call sm-check-equal,$(sm.this.sources.TeX),cwebman.tex $(prefix)/ctangle.tex $(prefix)/common.tex)
$(call sm-check-equal,$(sm.this.intermediates),$(sm.out.inter)/$(prefix)/ctangle.o $(sm.out.inter)/$(prefix)/common.o)
$(call sm-check-equal,$(sm.this.sources.has.c),true)
#$(call sm-check-equal,$(sm.this.sources.has.TeX),true)
