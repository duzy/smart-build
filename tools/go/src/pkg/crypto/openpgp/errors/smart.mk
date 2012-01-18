#
$(call go-new-module, crypto/openpgp/errors, pkg)

GOFILES=\
	errors.go\

sm.this.sources := $(GOFILES)
sm.this.depends += goal-crypto

$(go-build-this)
