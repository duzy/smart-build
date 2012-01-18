#
$(call go-new-module, go/printer, pkg)

GOFILES=\
	printer.go\
	nodes.go\

sm.this.sources := $(GOFILES)
sm.this.depends += goal-text/tabwriter

$(go-build-this)
