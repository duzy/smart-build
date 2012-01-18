#
$(call go-new-module, hash/fnv, pkg)

GOFILES=\
	fnv.go\

sm.this.sources := $(GOFILES)

$(go-build-this)
