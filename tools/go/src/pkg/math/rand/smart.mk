#
$(call go-new-module, math/rand, pkg)

GOFILES=\
	exp.go\
	normal.go\
	rand.go\
	rng.go\
	zipf.go\

sm.this.sources := $(GOFILES)

$(go-build-this)
