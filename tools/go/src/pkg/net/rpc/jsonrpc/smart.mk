#
$(call go-new-module, net/rpc/jsonrpc, pkg)

GOFILES=\
	client.go\
	server.go\

sm.this.sources := $(GOFILES)

$(go-build-this)
