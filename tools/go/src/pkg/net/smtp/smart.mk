#
$(call go-new-module, net/smtp, pkg)

GOFILES=\
	auth.go\
	smtp.go\

sm.this.sources := $(GOFILES)

$(go-build-this)
