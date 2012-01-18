#
$(call go-new-module, net/http/fcgi, pkg)

GOFILES=\
	child.go\
	fcgi.go\

sm.this.sources := $(GOFILES)

$(go-build-this)
