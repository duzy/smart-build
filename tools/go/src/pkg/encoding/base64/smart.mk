#
$(call go-new-module, encoding/base64, pkg)

GOFILES=\
	base64.go\

sm.this.sources := $(GOFILES)

$(go-build-this)
