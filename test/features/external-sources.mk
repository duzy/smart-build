#
#
$(call test-check-undefined, sm.this.dir)
$(call sm-new-module, feature-external-sources, gcc: exe)

sm.this.sources.external := $(sm.this.dir)/main.c
sm.this.compile.flags := -DTEST=\"test\"

$(sm-build-this)
