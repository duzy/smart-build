#
$(call go-new-module, encoding/ascii85, pkg)

GOFILES=\
	ascii85.go\

sm.this.sources := $(GOFILES)

$(go-build-this)
