#
#  Copyright (c) 2011-09-20
#

$(call sm-new-module, foo, exe, gcc)

sm.this.lang := c++
sm.this.sources := foo1.c foo2.cpp foo3.web foo4.w foo5.nw

$(sm-build-this)

$(info foo: ==================================================)

$(info foo: sources: c: $(sm.this.sources.c))
$(info foo: sources: c: $(sm.var.foo.sources.c))
$(info foo: sources: c++: $(sm.this.sources.c++))
$(info foo: sources: c++: $(sm.var.foo.sources.c++))
$(info foo: sources: pascal: $(sm.this.sources.pascal))
$(info foo: sources: pascal: $(sm.var.foo.sources.pascal))
$(info foo: sources: cweb: $(sm.this.sources.cweb))
$(info foo: sources: cweb: $(sm.var.foo.sources.cweb))
$(info foo: sources: common: $(sm.this.sources.common))
$(info foo: sources: common: $(sm.var.foo.sources.common))
$(info foo: sources: all: $(sm.var.foo.sources))

$(call sm-check-equal,$(sm.this.sources.c),foo1.c)
$(call sm-check-equal,$(sm.this.sources.c++),foo2.cpp $(sm.out.inter)/foo4.cpp $(sm.out.inter)/foo5.cpp)
$(call sm-check-equal,$(sm.this.sources.pascal),$(sm.out.inter)/foo3.p)
$(call sm-check-equal,$(sm.this.sources.cweb),foo4.w)
$(call sm-check-equal,$(sm.this.sources.common),foo3.web foo4.w foo5.nw)
$(call sm-check-equal,$(sm.var.foo.sources.c),foo1.c)
$(call sm-check-equal,$(sm.var.foo.sources.c++),foo2.cpp $(sm.out.inter)/foo4.cpp $(sm.out.inter)/foo5.cpp)
#$(call sm-check-equal,$(sm.var.foo.sources.pascal),$(sm.out.inter)/foo3.p)
$(call sm-check-equal,$(sm.var.foo.sources.cweb),foo4.w)
$(call sm-check-equal,$(sm.var.foo.sources.common),foo3.web foo4.w foo5.nw)
#$(call sm-check-equal,$(sm.var.foo.sources))
