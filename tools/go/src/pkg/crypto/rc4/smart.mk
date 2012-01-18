#
$(call go-new-module, crypto/rc4, pkg)

GOFILES=\
	rc4.go\

sm.this.sources := $(GOFILES)
sm.this.depends += goal-crypto

$(go-build-this)
