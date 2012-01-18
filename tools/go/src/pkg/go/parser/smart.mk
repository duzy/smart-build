#
$(call go-new-module, go/parser, pkg)

GOFILES=\
	interface.go\
	parser.go\

sm.this.sources := $(GOFILES)

$(go-build-this)
