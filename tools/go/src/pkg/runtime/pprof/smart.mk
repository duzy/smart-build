#
$(call go-new-module, runtime/pprof, pkg)

GOFILES=\
	pprof.go\

sm.this.sources := $(GOFILES)

$(go-build-this)
