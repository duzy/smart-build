#
$(call go-new-module, encoding/binary, pkg)

GOFILES=\
	binary.go\
        varint.go\

sm.this.sources := $(GOFILES)

$(go-build-this)
