#
$(call go-new-module, crypto/openpgp/s2k, pkg)

GOFILES=\
	s2k.go\

sm.this.sources := $(GOFILES)
sm.this.depends += goal-crypto goal-crypto/openpgp/errors

$(go-build-this)
