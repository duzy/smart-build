#
$(call go-new-module, sort, pkg)

GOFILES=\
	search.go\
	sort.go\

sm.this.sources := $(GOFILES)

$(go-build-this)
