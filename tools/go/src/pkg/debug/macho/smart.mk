#
$(call go-new-module, debug/macho, pkg)

GOFILES=\
	macho.go\
	file.go\

sm.this.sources := $(GOFILES)

$(go-build-this)
