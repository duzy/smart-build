#
$(call go-new-module, encoding/gob, pkg)

GOFILES=\
	decode.go\
	decoder.go\
	doc.go\
	encode.go\
	encoder.go\
	error.go\
	type.go\

sm.this.sources := $(GOFILES)
sm.this.depends += goal-bufio

$(go-build-this)
