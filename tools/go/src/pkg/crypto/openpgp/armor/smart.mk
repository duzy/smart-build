#
$(call go-new-module, crypto/openpgp/armor, pkg)

GOFILES=\
	armor.go\
	encode.go\

sm.this.sources := $(GOFILES)
sm.this.depends += goal-crypto goal-crypto/openpgp/errors

$(go-build-this)
