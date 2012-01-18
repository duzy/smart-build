#
$(call go-new-module, net/dict, pkg)

GOFILES=\
	dict.go\

sm.this.sources := $(GOFILES)

$(go-build-this)
