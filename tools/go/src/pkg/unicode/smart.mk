#
$(call go-new-module, unicode, pkg)

GOFILES=\
	casetables.go\
	digit.go\
	graphic.go\
	letter.go\
	tables.go\

sm.this.sources := $(GOFILES)

$(go-build-this)
