#
$(call go-new-module, debug/pe, pkg)

GOFILES=\
	pe.go\
	file.go\

sm.this.sources := $(GOFILES)

$(go-build-this)
