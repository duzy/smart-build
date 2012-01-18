#
$(call go-new-module, container/list, pkg)

GOFILES=\
	list.go\

sm.this.sources := $(GOFILES)

$(go-build-this)
