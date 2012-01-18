#
$(call go-new-module, crypto/blowfish, pkg)

GOFILES=\
	block.go\
	cipher.go\
	const.go\

sm.this.sources := $(GOFILES)
sm.this.depends += goal-crypto

$(go-build-this)
