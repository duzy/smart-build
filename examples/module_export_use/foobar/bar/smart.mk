#

$(info foobar/bar: using: foobar/bar/smart.mk loaded)

$(call sm-new-module, bar, shared, gcc)

sm.this.verbose := true
sm.this.sources := bar.cpp
sm.this.compile.flags := -fPIC

sm.this.export.defines := -DTEST_BAR=defined_by_foobar_bar
sm.this.export.includes := $(sm.this.dir)/inc
sm.this.export.link.flags := -DTEST_BAR_LINK=\\"defined by foobar/bar\\"
sm.this.export.libdirs := $(sm.out.lib)
sm.this.export.libs := bar

$(sm-build-this)
