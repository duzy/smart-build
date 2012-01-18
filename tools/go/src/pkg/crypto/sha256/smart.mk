#
$(call go-new-module, crypto/sha256, pkg)

GOFILES=\
	sha256.go\
	sha256block.go\

sm.this.sources := $(GOFILES)
sm.this.depends += goal-crypto

$(go-build-this)
