#
$(call go-new-module, bufio, pkg)

GOFILES=\
	bufio.go\

sm.this.sources := $(GOFILES)

$(go-build-this)
