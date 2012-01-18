#
$(call go-new-module, crypto/xtea, pkg)

GOFILES=\
	cipher.go\
	block.go\

sm.this.sources := $(GOFILES)
sm.this.depends += goal-crypto

$(go-build-this)
