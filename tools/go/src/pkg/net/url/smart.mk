#
$(call go-new-module, net/url, pkg)

GOFILES_$(GOOS) :=
GOFILES=\
	url.go\

sm.this.sources := $(GOFILES)

$(go-build-this)
