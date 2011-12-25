#
#
$(call test-check-module-empty, sm.this)
$(call test-check-module-empty, sm.module.toolset-go-package)
$(call sm-new-module, toolset-go-package, go: package)

sm.this.sources := foo.go foo.c
sm.this.export.compile.flags := -I$(sm.out.lib)
sm.this.export.link.flags := -L$(sm.out.lib)

$(sm-build-this)
