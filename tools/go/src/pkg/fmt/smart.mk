#
$(call go-new-module, fmt, pkg)

GOFILES=\
	doc.go\
	format.go\
	print.go\
	scan.go\

sm.this.sources := $(GOFILES)

$(go-build-this)
