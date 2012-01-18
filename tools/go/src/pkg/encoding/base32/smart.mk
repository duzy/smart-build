#
$(call go-new-module, encoding/base32, pkg)

GOFILES=\
	base32.go\

sm.this.sources := $(GOFILES)

$(go-build-this)
