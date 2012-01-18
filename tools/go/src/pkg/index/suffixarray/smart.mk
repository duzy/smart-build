#
$(call go-new-module, index/suffixarray, pkg)

GOFILES=\
	qsufsort.go\
	suffixarray.go\

sm.this.sources := $(GOFILES)

$(go-build-this)
