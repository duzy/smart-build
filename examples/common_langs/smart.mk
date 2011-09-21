#
#  Copyright (c) 2011-09-20
#

$(call sm-new-module, foo, exe, gcc)

sm.this.lang := c++
sm.this.sources := main.w foo.nw foo.web

$(sm-build-this)

#$(call sm-check-equal,$(sm.this.sources.c++))
$(call sm-check-equal,$(sm.this.sources.cweb),main.w)
$(call sm-check-equal,$(sm.this.sources.common),main.w foo.nw foo.web)
#$(call sm-check-equal,$(sm.var.foo.sources.c++))
$(call sm-check-equal,$(sm.var.foo.sources.cweb),main.w)
$(call sm-check-equal,$(sm.var.foo.sources.common),main.w foo.nw foo.web)
#$(call sm-check-equal,$(sm.var.foo.sources))

$(info foo: sources: c++: $(sm.this.sources.c++))
$(info foo: sources: c++: $(sm.var.foo.sources.c++))
$(info foo: sources: cweb: $(sm.this.sources.cweb))
$(info foo: sources: cweb: $(sm.var.foo.sources.cweb))
$(info foo: sources: common: $(sm.this.sources.common))
$(info foo: sources: common: $(sm.var.foo.sources.common))
$(info foo: sources: $(sm.var.foo.sources))
