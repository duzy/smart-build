#

$(call sm-check-empty, sm.this.dir)
$(call sm-new-module, foo2, shared, gcc)

$(info $(sm.this.dir))

sm.this.verbose := true
sm.this.sources := foo.cpp
sm.this.compile.flags := -fPIC

$(sm-build-this)
