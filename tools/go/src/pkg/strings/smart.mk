#
$(call go-new-module, strings, pkg)

GOFILES=\
	reader.go\
	replace.go\
	strings.go\

sm.this.sources := $(GOFILES)

$(go-build-this)
