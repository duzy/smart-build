#
$(call go-new-module, crypto/des, pkg)

GOFILES=\
	block.go\
	cipher.go\
	const.go\

sm.this.sources := $(GOFILES)
sm.this.depends += goal-crypto

$(go-build-this)
