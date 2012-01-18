#
$(call go-new-module, encoding/xml, pkg)

GOFILES=\
	marshal.go\
	read.go\
	typeinfo.go\
	xml.go\

sm.this.sources := $(GOFILES)

$(go-build-this)
