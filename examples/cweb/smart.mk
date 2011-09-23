#

$(call sm-new-module, foo, exe, gcc)

sm.this.lang := c++
sm.this.sources := main.w

$(sm-build-this)

$(info foo: $(sm.var.foo.sources.c++))
$(info foo: $(sm.this.sources.c++))
