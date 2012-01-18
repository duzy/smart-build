#
$(call go-new-module, net/http/httputil, pkg)

GOFILES=\
	chunked.go\
	dump.go\
	persist.go\
	reverseproxy.go\

sm.this.sources := $(GOFILES)

$(go-build-this)
