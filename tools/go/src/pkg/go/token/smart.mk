#
$(call go-new-module, go/token, pkg)

GOFILES=\
	position.go\
	serialize.go\
	token.go\

sm.this.sources := $(GOFILES)

$(go-build-this)
