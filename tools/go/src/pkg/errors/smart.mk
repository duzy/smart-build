#
$(call go-new-module, errors, pkg)

sm.this.sources := errors.go

$(go-build-this)
