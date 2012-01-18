#
$(call go-new-module, crypto/dsa, pkg)

GOFILES=\
	dsa.go\

sm.this.sources := $(GOFILES)
sm.this.depends += goal-crypto

$(go-build-this)
