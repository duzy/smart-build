#

$(call sm-new-module, foo, shared)

sm.this.verbose := true
sm.this.toolset := gcc
sm.this.sources := foo.cpp
sm.this.link.options := -Wl,--out-implib,$(sm.out.lib)/libfoo.a

$(sm-build-this)
