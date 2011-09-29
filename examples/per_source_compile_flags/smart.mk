
$(call sm-new-module, foobar, exe, gcc)

sm.this.verbose := true

sm.this.sources := foo.cpp bar.cpp main.cpp

sm.this.compile.flags := -g
sm.this.compile.flags-foo.cpp := -DTEST=\"foo\"
sm.this.compile.flags-bar.cpp := -DTEST=\"bar\"
sm.this.link.flags := -Dfoobar

$(sm-build-this)
