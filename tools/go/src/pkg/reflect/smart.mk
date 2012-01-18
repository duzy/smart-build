#
$(call go-new-module, reflect, pkg)

GOFILES=\
	deepequal.go\
	type.go\
	value.go\

sm.this.sources := $(GOFILES)

$(go-build-this)
