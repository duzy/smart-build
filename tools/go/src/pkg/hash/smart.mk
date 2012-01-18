#
$(call go-new-module, hash, pkg)

GOFILES=\
	hash.go\

sm.this.sources := $(GOFILES)

$(go-build-this)
