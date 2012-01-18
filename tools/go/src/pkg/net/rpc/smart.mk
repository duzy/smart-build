#
$(call go-new-module, net/rpc, pkg)

GOFILES=\
	client.go\
	debug.go\
	server.go\

sm.this.sources := $(GOFILES)

$(go-build-this)
