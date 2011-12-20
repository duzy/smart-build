#
#
$(call test-check-undefined, sm.this.dir)
$(call sm-new-module, feature-compile-sources, gcc: exe)

sm.this.compile.flags := -DTEST=\"foo\"
sm.this.sources := foo.c
$(sm-compile-sources)

sm.this.compile.flags := -DTEST=\"bar\"
sm.this.sources := bar.c
$(sm-compile-sources)

sm.this.compile.flags := -DTEST=\"foobar\"
sm.this.sources := foobar.c
$(sm-build-this)
