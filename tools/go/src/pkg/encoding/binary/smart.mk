#
$(call go-new-module, encoding/binary, pkg)

GOFILES=\
	binary.go\
        varint.go\

sm.this.sources := $(GOFILES)
sm.this.depends += goal-errors goal-math goal-reflect

$(go-build-this)
