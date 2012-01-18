#
$(call go-new-module, crypto/cipher, pkg)

GOFILES=\
	cbc.go\
	cfb.go\
	cipher.go\
	ctr.go\
	io.go\
	ocfb.go\
	ofb.go

sm.this.sources := $(GOFILES)
sm.this.depends += goal-crypto

$(go-build-this)
