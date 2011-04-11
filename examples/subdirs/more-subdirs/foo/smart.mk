#

$(call sm-check-empty, sm.this.dir)
$(call sm-new-module, foo2, shared)

$(info $(sm.this.dir))

sm.this.verbose := true
sm.this.toolset := gcc
sm.this.sources := foo.cpp

$(sm-build-this)
