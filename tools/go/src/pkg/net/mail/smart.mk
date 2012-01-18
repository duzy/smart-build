#
$(call go-new-module, net/mail, pkg)

GOFILES=\
	message.go\

sm.this.sources := $(GOFILES)

$(go-build-this)
