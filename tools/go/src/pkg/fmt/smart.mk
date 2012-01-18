#
$(call go-new-module, fmt, pkg)

GOFILES=\
	doc.go\
	format.go\
	print.go\
	scan.go\

sm.this.sources := $(GOFILES)
sm.this.depends += goal-os

$(go-build-this)
