#
$(call go-new-module, encoding/asn1, pkg)

GOFILES=\
	asn1.go\
	common.go\
	marshal.go\

sm.this.sources := $(GOFILES)
sm.this.depends += goal-math/big

$(go-build-this)
