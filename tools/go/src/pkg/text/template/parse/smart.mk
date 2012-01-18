#
$(call go-new-module, text/template/parse, pkg)

GOFILES=\
	lex.go\
	node.go\
	parse.go\

sm.this.sources := $(GOFILES)

$(go-build-this)
