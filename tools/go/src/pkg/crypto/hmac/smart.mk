#
$(call go-new-module, crypto/hmac, pkg)

GOFILES=\
	hmac.go\

sm.this.sources := $(GOFILES)
sm.this.depends += goal-crypto goal-crypto/sha1 goal-crypto/sha256

$(go-build-this)
