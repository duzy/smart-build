#
#
$(call test-check-undefined, sm.this.dir)
$(call sm-new-module, feature-per-source-compile-flags, gcc: exe)

sm.this.sources := foo.c bar.c foobar.c
sm.this.compile.flags := -g
sm.this.compile.flags-foo.c := -DTEST=\"foo\"
sm.this.compile.flags-bar.c := -DTEST=\"bar\"
sm.this.link.flags := -Dfoobar

$(sm-build-this)
$(call test-check-value-of,sm.module.feature-per-source-compile-flags.compile.flags-foo.c,-DTEST=\"foo\")
$(call test-check-value-of,sm.module.feature-per-source-compile-flags.compile.flags-bar.c,-DTEST=\"bar\")
