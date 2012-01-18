#
$(call go-new-module, encoding/git85, pkg)

GOFILES=\
	git.go\

sm.this.sources := $(GOFILES)

$(go-build-this)
