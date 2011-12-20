#
#
$(call test-check-undefined, sm.this.dir)
$(call sm-new-module, mixture-sources, gcc: exe)

sm.this.compile.flags := -DTEST=\"foo\"
sm.this.sources := foo.c foo.cpp foo.go main.c

$(sm-build-this)
$(call test-check-value-of,sm.module.mixture-sources.lang,c++)
$(call test-check-value-of,sm.module.mixture-sources.langs,c++ go c)
