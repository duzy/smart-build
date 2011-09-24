#

$(call sm-new-module, foo, exe, gcc)

sm.this.lang := c++
sm.this.sources := main.w

$(sm-build-this)

$(call sm-check-equal,$(strip $(sm.var.foo.sources.c++)),$(sm.out.inter)/main.cpp)
$(call sm-check-equal,$(strip $(sm.this.sources.c++)),$(sm.out.inter)/main.cpp)
$(call sm-check-equal,$(strip $(sm.this.objects)),$(sm.out.obj)/$(sm.out.inter)/main.o)
