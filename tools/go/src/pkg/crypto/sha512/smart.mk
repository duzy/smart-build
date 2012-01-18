#
$(call go-new-module, crypto/sha512, pkg)

GOFILES=\
	sha512.go\
	sha512block.go\

sm.this.sources := $(GOFILES)
sm.this.depends += goal-crypto

$(go-build-this)
