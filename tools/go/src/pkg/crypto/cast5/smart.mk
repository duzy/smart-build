#
$(call go-new-module, crypto/cast5, pkg)

GOFILES=\
	cast5.go\

sm.this.sources := $(GOFILES)
sm.this.depends += goal-crypto

$(go-build-this)
