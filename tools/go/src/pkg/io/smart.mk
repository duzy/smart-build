#
$(call go-new-module, io, pkg)

GOFILES=\
	io.go\
	multi.go\
	pipe.go\

sm.this.sources := $(GOFILES)

$(go-build-this)
