#

$(call sm-new-module, foo, exe, gcc)

sm.this.lang := c++
sm.this.sources := main.w

$(sm-build-this)

prefix := $(sm.out.inter)/common
$(call sm-check-equal,$(strip $(sm.var.foo.sources.c++)),$(prefix)/main.cpp)
$(call sm-check-equal,$(strip $(sm.this.sources.c++)),$(prefix)/main.cpp)
$(call sm-check-equal,$(strip $(sm.this.inters)),$(sm.out.inter)/$(prefix)/main.o)
