#
$(call go-new-module, crypto, pkg)

GOFILES=\
	crypto.go\

sm.this.sources := $(GOFILES)

$(go-build-this)
