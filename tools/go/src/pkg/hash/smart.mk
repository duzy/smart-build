#
$(call go-new-module, hash, pkg)

GOFILES=\
	hash.go\

sm.this.sources := $(GOFILES)
sm.this.depends += goal-io

$(go-build-this)
