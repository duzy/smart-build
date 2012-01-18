#
$(call go-new-module, hash/adler32, pkg)

GOFILES=\
	adler32.go\

sm.this.sources := $(GOFILES)

$(go-build-this)
