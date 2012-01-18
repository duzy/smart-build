#
$(call go-new-module, net/http/cgi, pkg)

GOFILES=\
	child.go\
	host.go\

sm.this.sources := $(GOFILES)
#sm.this.depends += goal-runtime/debug

$(go-build-this)
