#
#  Copyright (c) 2011-09-20
#

$(call sm-new-module, foo, exe, gcc)

sm.this.lang := c++
sm.this.sources := foo.web foo.w foo.nw

$(sm-build-this)

#$(call sm-check-equal,$(sm.this.sources.c++))
#$(call sm-check-equal,$(sm.this.sources.pascal))
$(call sm-check-equal,$(sm.this.sources.cweb),foo.w)
$(call sm-check-equal,$(sm.this.sources.common),foo.web foo.w foo.nw)
#$(call sm-check-equal,$(sm.var.foo.sources.c++))
#$(call sm-check-equal,$(sm.var.foo.sources.pascal))
$(call sm-check-equal,$(sm.var.foo.sources.cweb),foo.w)
$(call sm-check-equal,$(sm.var.foo.sources.common),foo.web foo.w foo.nw)
#$(call sm-check-equal,$(sm.var.foo.sources))

$(info foo: sources: c++: $(sm.this.sources.c++))
$(info foo: sources: c++: $(sm.var.foo.sources.c++))
$(info foo: sources: pascal: $(sm.this.sources.pascal))
$(info foo: sources: pascal: $(sm.var.foo.sources.pascal))
$(info foo: sources: cweb: $(sm.this.sources.cweb))
$(info foo: sources: cweb: $(sm.var.foo.sources.cweb))
$(info foo: sources: common: $(sm.this.sources.common))
$(info foo: sources: common: $(sm.var.foo.sources.common))
$(info foo: sources: all: $(sm.var.foo.sources))
