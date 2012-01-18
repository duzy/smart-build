#
$(call go-new-module, flag, pkg)

GOFILES=\
	flag.go\

sm.this.sources := $(GOFILES)

$(go-build-this)
