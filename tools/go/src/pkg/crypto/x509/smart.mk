#
$(call go-new-module, crypto/x509, pkg)

GOFILES=\
	cert_pool.go\
	pkcs1.go\
	pkcs8.go\
	verify.go\
	x509.go\

sm.this.sources := $(GOFILES)
sm.this.depends += goal-crypto goal-encoding/pem goal-crypto/x509/pkix

$(go-build-this)
