#
#
$(call sm-new-module, feature-external-sources, exe, gcc)

sm.this.sources.external := $(sm.this.dir)/main.c
sm.this.compile.flags := -DTEST=\"test\"

$(sm-build-this)
