#
#
$(call test-check-module-empty, sm.this)
$(call test-check-module-empty, sm.module.toolset-go-package)
$(call sm-new-module, toolset-go-package, go: package)

sm.this.sources := foo.go

$(sm-build-this)
