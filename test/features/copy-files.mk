#
#
$(call test-check-undefined, sm.this.dir)
$(call test-check-module-empty, sm.this)
$(call sm-new-module, feature-copy-files, utils: copy)

sm.this.destination := $(sm.top)/out
sm.this.sources.copy := foo.txt foo.in
sm.this.chmod := 0644

$(sm-build-this)
#$(call test-check-value-of,sm.module.feature-copy-files.targets,$(sm.top)/out/foo.txt $(sm.top)/out/foo.in)
$(call test-check-value-of,sm.module.feature-copy-files.targets.copied,$(sm.top)/out/foo.txt $(sm.top)/out/foo.in)
