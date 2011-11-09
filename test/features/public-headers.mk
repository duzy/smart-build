#
#
$(call test-check-undefined, sm.this.dir)
$(call sm-new-module, feature-public-headers, depends)

sm.this.headers.test/features := foo.h bar.h

$(sm-build-this)
