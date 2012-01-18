#
$(call go-new-module, encoding/pem, pkg)

GOFILES=\
	pem.go\

sm.this.sources := $(GOFILES)

$(go-build-this)
