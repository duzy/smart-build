#
#
$(call test-check-undefined, sm.this.dir)
$(call sm-new-module, feature-copy-files, none: depends)

$(call sm-copy-files, foo.txt, $(sm.top)/out)

$(sm-build-this)
