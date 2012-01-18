#
$(call go-new-module, encoding/csv, pkg)

GOFILES=\
	reader.go\
	writer.go\

sm.this.sources := $(GOFILES)

$(go-build-this)
