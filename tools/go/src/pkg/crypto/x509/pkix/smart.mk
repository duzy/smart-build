#
$(call go-new-module, crypto/x509/pkix, pkg)

GOFILES=\
	pkix.go\

sm.this.sources := $(GOFILES)
sm.this.depends += goal-crypto

$(go-build-this)
