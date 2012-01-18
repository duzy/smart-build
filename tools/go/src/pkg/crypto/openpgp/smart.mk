#
$(call go-new-module, crypto/openpgp, pkg)

GOFILES=\
	canonical_text.go\
	keys.go\
	read.go\
	write.go\

sm.this.sources := $(GOFILES)
sm.this.depends +=\
  goal-crypto\
  goal-crypto/openpgp/armor\
  goal-crypto/openpgp/packet\

$(go-build-this)
