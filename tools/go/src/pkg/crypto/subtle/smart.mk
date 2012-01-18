#
$(call go-new-module, crypto/subtle, pkg)

GOFILES=\
	constant_time.go\

sm.this.sources := $(GOFILES)
sm.this.depends += goal-crypto

$(go-build-this)
