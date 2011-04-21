#

$(call sm-check-empty, sm.this.dir)
$(call sm-new-module, bar, static, gcc)

$(info $(sm.this.dir))

sm.this.verbose := true
sm.this.sources := bar.cpp
sm.this.includes := $(sm.this.dir)

$(sm-build-this)
