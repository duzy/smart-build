#
$(call go-new-module, net/http/pprof, pkg)

GOFILES=\
	pprof.go\

sm.this.sources := $(GOFILES)
sm.this.depends += goal-runtime/pprof

$(go-build-this)
