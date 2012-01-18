#
$(call go-new-module, compress/lzw, pkg)

GOFILES=\
	reader.go\
	writer.go\

sm.this.sources := $(GOFILES)

$(go-build-this)
