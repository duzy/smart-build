#
$(call go-new-module, crypto/sha1, pkg)

GOFILES=\
	sha1.go\
	sha1block.go\

sm.this.sources := $(GOFILES)
sm.this.depends += goal-crypto

$(go-build-this)
