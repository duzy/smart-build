#
$(call go-new-module, encoding/json, pkg)

GOFILES=\
	decode.go\
	encode.go\
	indent.go\
	scanner.go\
	stream.go\
	tags.go\

sm.this.sources := $(GOFILES)

$(go-build-this)
