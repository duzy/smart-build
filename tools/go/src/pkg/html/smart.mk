#
$(call go-new-module, html, pkg)

GOFILES=\
	const.go\
	doc.go\
	doctype.go\
	entity.go\
	escape.go\
	foreign.go\
	node.go\
	parse.go\
	render.go\
	token.go\

sm.this.sources := $(GOFILES)

$(go-build-this)
