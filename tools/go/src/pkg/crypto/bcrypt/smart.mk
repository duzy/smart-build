#
$(call go-new-module, crypto/bcrypt, pkg)

GOFILES=\
	base64.go \
	bcrypt.go

sm.this.sources := $(GOFILES)
sm.this.depends +=\
    goal-encoding/base64\
    goal-crypto\
    goal-crypto/rand\
    goal-crypto/subtle\

$(go-build-this)
