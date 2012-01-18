#
$(call go-new-module, crypto/elliptic, pkg)

GOFILES=\
	elliptic.go\

sm.this.sources := $(GOFILES)
sm.this.depends += goal-crypto

$(go-build-this)
