#
#
$(call sm-new-module, foo, exe, clang)

sm.this.verbose := true
sm.this.sources := main.cpp foo.cpp bar.c

$(sm-build-this)
