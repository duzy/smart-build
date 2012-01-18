#
$(call go-new-module, container/heap, pkg)

GOFILES=\
	heap.go\

sm.this.sources := $(GOFILES)

$(go-build-this)
