#
$(call go-new-module, runtime/debug, pkg)

GOFILES=\
	stack.go\

sm.this.sources := $(GOFILES)

$(go-build-this)
