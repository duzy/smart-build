#
$(call go-new-module, crypto/ripemd160, pkg)

GOFILES=\
	ripemd160.go\
	ripemd160block.go\

sm.this.sources := $(GOFILES)
sm.this.depends += goal-crypto

$(go-build-this)
