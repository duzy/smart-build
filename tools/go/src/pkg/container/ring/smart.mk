#
$(call go-new-module, container/ring, pkg)

GOFILES=\
	ring.go\

sm.this.sources := $(GOFILES)

$(go-build-this)
