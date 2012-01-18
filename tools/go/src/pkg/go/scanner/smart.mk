#
$(call go-new-module, go/scanner, pkg)

GOFILES=\
	errors.go\
	scanner.go\

sm.this.sources := $(GOFILES)

$(go-build-this)
