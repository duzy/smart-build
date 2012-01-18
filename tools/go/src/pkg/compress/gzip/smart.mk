#
$(call go-new-module, compress/gzip, pkg)

GOFILES=\
	gunzip.go\
	gzip.go\

sm.this.sources := $(GOFILES)

$(go-build-this)
