#
$(call go-new-module, websocket, pkg)

GOFILES=\
	client.go\
	server.go\
	websocket.go\
	hixie.go\
	hybi.go\

sm.this.sources := $(GOFILES)

$(go-build-this)
