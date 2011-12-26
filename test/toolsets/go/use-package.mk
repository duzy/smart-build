#
#
$(call test-check-module-empty, sm.this)
$(call test-check-module-empty, sm.module.toolset-go-command2)
$(call sm-new-module, toolset-go-command2, go: command)
$(call sm-use,toolset_go_package)

sm.this.sources := main2.go

$(sm-build-this)
