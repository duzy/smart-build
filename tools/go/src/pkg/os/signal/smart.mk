#
$(call go-new-module, os/signal, pkg)

GOFILES=\
	signal.go\

sm.this.sources := $(GOFILES)
sm.this.depends +=

$(go-build-this)
