#
$(call go-new-module, hash/crc64, pkg)

GOFILES=\
	crc64.go\

sm.this.sources := $(GOFILES)

$(go-build-this)
