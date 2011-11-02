#

$(call sm-new-module, foo, shared, gcc)

sm.this.verbose := true
sm.this.sources := foo.cpp
sm.this.compile.flags := -fPIC
sm.this.link.flags := -fPIC
sm.this.depends := $(sm.out)/foo.txt

$(sm.out)/foo.txt: ; mkdir -p $(@D) && echo foo > $@

$(sm-build-this)
