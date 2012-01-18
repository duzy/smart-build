#
$(call go-new-module, text/tabwriter, pkg)

GOFILES=\
	tabwriter.go\

sm.this.sources := $(GOFILES)

$(go-build-this)
