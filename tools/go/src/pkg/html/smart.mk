#
$(call go-new-module, html, pkg)

GOFILES=\
	entity.go\
	escape.go\

sm.this.sources := $(GOFILES)

$(go-build-this)
