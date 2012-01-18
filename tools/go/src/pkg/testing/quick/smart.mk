#
$(call go-new-module, testing/quick, pkg)

GOFILES=\
	quick.go\

sm.this.sources := $(GOFILES)

$(go-build-this)
