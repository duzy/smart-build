#
$(call go-new-module, html/template, pkg)

GOFILES=\
	attr.go\
	clone.go\
	content.go\
	context.go\
	css.go\
	doc.go\
	error.go\
	escape.go\
	html.go\
	js.go\
	template.go\
	transition.go\
	url.go\

sm.this.sources := $(GOFILES)

$(go-build-this)
