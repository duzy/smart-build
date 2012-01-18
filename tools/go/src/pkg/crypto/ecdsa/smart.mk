#
$(call go-new-module, crypto/ecdsa, pkg)

GOFILES=\
	ecdsa.go\

sm.this.sources := $(GOFILES)
sm.this.depends += goal-crypto goal-crypto/elliptic

$(go-build-this)
