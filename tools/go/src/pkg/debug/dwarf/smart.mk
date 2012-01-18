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
sm.this.depends += goal-encoding/binary

$(go-build-this)
