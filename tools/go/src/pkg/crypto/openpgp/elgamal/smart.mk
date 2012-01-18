#
$(call go-new-module, crypto/openpgp/elgamal, pkg)

GOFILES=\
	elgamal.go\

sm.this.sources := $(GOFILES)
sm.this.depends += goal-crypto goal-crypto/openpgp/errors

$(go-build-this)
