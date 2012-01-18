#
$(call go-new-module, unicode/utf16, pkg)

GOFILES=\
	utf16.go\

sm.this.sources := $(GOFILES)

$(go-build-this)
