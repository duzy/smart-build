#

$(call sm-check-empty, sm.this.dir)
$(call sm-new-module, bar2, static)

$(info $(sm.this.dir))

sm.this.verbose := true
sm.this.toolset := gcc
sm.this.sources := bar.cpp
sm.this.includes := $(sm.this.dir)

$(sm-build-this)
