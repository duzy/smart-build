#
$(call go-new-module, log, pkg)

sm.this.sources := log.go

$(go-build-this)
