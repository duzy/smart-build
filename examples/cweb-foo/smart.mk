#

$(call sm-new-module, foo, exe, gcc)

sm.this.lang := c++
sm.this.sources := main.w

$(sm-build-this)

prefix := $(sm.out.inter)/common
$(call sm-check-equal,$(sm.module.foo.sources.unknown),)
$(call sm-check-equal,$(sm.module.foo.sources.common),main.w)
$(call sm-check-equal,$(sm.module.foo.sources.cweb),main.w)
$(call sm-check-equal,$(sm.module.foo.sources.has.cweb),true)
$(call sm-check-equal,$(sm.module.foo.sources.c++),$(prefix)/main.cpp)
$(call sm-check-equal,$(sm.module.foo.sources.has.c++),true)
$(call sm-check-equal,$(sm.module.foo.intermediates),$(sm.out.inter)/$(prefix)/main.o)
$(call sm-check-equal,$(sm.module.foo.targets),$(sm.out.bin)/foo)
$(call sm-check-equal,$(sm.module.foo.module_targets),$(sm.out.bin)/foo)
$(call sm-check-equal,$(sm.module.foo.user_defined_targets),)
$(call sm-check-equal,$(strip $(sm.this.sources.c++)),$(prefix)/main.cpp)
$(call sm-check-equal,$(strip $(sm.this.inters)),$(sm.out.inter)/$(prefix)/main.o)
