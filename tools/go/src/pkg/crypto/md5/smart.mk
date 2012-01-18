#
$(call go-new-module, crypto/md5, pkg)

GOFILES=\
	md5.go\
	md5block.go\

sm.this.sources := $(GOFILES)
sm.this.depends += goal-crypto

$(go-build-this)
