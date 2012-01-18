#
$(call go-new-module, net/textproto, pkg)

GOFILES=\
	header.go\
	pipeline.go\
	reader.go\
	textproto.go\
	writer.go\

sm.this.sources := $(GOFILES)

$(go-build-this)
