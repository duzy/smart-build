#
$(call go-new-module, debug/dwarf, pkg)

GOFILES=\
	buf.go\
	const.go\
	entry.go\
	open.go\
	type.go\
	unit.go\

sm.this.sources := $(GOFILES)

$(go-build-this)
