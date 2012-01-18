#
$(call go-new-module, crypto/twofish, pkg)

GOFILES=\
	twofish.go\

sm.this.sources := $(GOFILES)
sm.this.depends += goal-crypto

$(go-build-this)
