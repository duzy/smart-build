#
$(call go-new-module, testing, pkg)

GOFILES=\
	benchmark.go\
	example.go\
	testing.go\

sm.this.sources := $(GOFILES)

$(go-build-this)
