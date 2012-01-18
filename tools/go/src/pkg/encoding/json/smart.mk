#
$(call go-new-module, encoding/json, pkg)

GOFILES=\
	decode.go\
	encode.go\
	indent.go\
	scanner.go\
	stream.go\
	tags.go\

sm.this.sources := $(GOFILES)
sm.this.depends += goal-unicode/utf16

$(go-build-this)
