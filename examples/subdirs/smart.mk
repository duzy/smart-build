#

$(call sm-new-module, foobar, shared)

sm.this.verbose := true
sm.this.includes := foo bar
sm.this.sources := foobar.cpp

$(sm-build-this)
$(sm-load-subdirs)
