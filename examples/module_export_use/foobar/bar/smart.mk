#

$(info test: using: foobar/bar/smart.mk loaded)

$(call sm-new-module, bar, shared, gcc)

sm.this.sources := bar.cpp
sm.this.compile.flags := -fPIC

sm.this.export.includes := $(sm.this.dir)/inc
sm.this.export.libs := bar

$(sm-generate-implib)
$(sm-build-this)
