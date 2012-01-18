#
$(call go-new-module, net/http/httptest, pkg)

GOFILES=\
	recorder.go\
	server.go\

sm.this.sources := $(GOFILES)

$(go-build-this)
