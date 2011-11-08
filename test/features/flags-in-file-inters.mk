#
#
$(call sm-new-module, feature-flags-in-file-inters, exe, gcc)

sm.this.compile.flags := -DTEST=\"$(sm.this.name)\"
sm.this.sources := main.c

sm.this.link.intermediates.infile := yes

$(sm-build-this)
