#
$(call go-new-module, crypto, pkg)

GOFILES=\
	crypto.go\

sm.this.sources := $(GOFILES)
sm.this.depends += goal-hash

$(go-build-this)
