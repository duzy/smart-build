#
#
$(call sm-new-module, feature-flags-in-file-compile, exe, gcc)

sm.this.compile.flags := -DTEST=\"$(sm.this.name)\"
sm.this.compile.flags.infile := yes
sm.this.sources := main.c

$(sm-build-this)
