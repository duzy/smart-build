#
$(call go-new-module, encoding/hex, pkg)

GOFILES=\
	hex.go\

sm.this.sources := $(GOFILES)

$(go-build-this)
