#
$(call go-new-module, crypto/ocsp, pkg)

GOFILES=\
	ocsp.go\

sm.this.sources := $(GOFILES)
sm.this.depends += goal-crypto goal-crypto/rsa goal-crypto/x509

$(go-build-this)
