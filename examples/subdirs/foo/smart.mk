#

$(call sm-new-module, foo, shared)

sm.this.verbose := true
sm.this.toolset := gcc
sm.this.sources := foo.cpp

$(sm-build-this)
