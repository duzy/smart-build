#
$(call go-new-module, crypto/rsa, pkg)

GOFILES=\
	rsa.go\
	pkcs1v15.go\

sm.this.sources := $(GOFILES)
sm.this.depends += goal-crypto

$(go-build-this)
