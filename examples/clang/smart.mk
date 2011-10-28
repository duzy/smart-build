#
#
$(call sm-new-module, foo, exe, clang)

sm.this.verbose := true
sm.this.sources := foo.cpp

$(sm-build-this)
