#
$(call go-new-module, path, pkg)

GOFILES=\
	match.go\
	path.go\

sm.this.sources := $(GOFILES)

$(go-build-this)
