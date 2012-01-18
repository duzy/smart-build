#
$(call go-new-module, testing/script, pkg)

GOFILES=\
	script.go\

sm.this.sources := $(GOFILES)

$(go-build-this)
