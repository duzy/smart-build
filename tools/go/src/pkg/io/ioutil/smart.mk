#
$(call go-new-module, io/ioutil, pkg)

GOFILES=\
	ioutil.go\
	tempfile.go\

sm.this.sources := $(GOFILES)

$(go-build-this)
