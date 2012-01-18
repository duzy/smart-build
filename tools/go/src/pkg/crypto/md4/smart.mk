#
$(call go-new-module, crypto/md4, pkg)

GOFILES=\
	md4.go\
	md4block.go\

sm.this.sources := $(GOFILES)
sm.this.depends += goal-crypto

$(go-build-this)
