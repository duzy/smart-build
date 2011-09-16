#

$(call sm-check-empty, sm.this.dir)
$(call sm-new-module, foo, shared, gcc)

$(info $(sm.this.dir))

sm.this.verbose := true
sm.this.sources := foo.cpp
sm.this.compile.flags := -fPIC

$(sm-generate-implib)
$(sm-build-this)
