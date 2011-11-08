#
#
$(call sm-new-module, feature-per-source-compile-flags, exe, gcc)

sm.this.sources := foo.c bar.c main.c
sm.this.compile.flags := -g
sm.this.compile.flags-foo.cpp := -DTEST=\"foo\"
sm.this.compile.flags-bar.cpp := -DTEST=\"bar\"
sm.this.link.flags := -Dfoobar

$(sm-build-this)
