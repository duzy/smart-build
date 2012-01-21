#
#
$(call test-check-module-empty, sm.this)
$(call test-check-module-empty, sm.module.toolset-go-command)
$(call sm-new-module, toolset-go-command, go: command)

sm.this.sources := main.go

$(sm-build-this)
