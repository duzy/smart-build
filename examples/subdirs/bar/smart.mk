#

$(call sm-new-module, bar, static)

sm.this.verbose := true
sm.this.toolset := gcc
sm.this.sources := bar.cpp
sm.this.includes := $(sm.this.dir)

$(sm-build-this)
