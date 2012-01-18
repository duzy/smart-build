#
$(call go-new-module, io, pkg)

GOFILES=\
	io.go\
	multi.go\
	pipe.go\

sm.this.sources := $(GOFILES)
sm.this.depends += goal-sync

$(go-build-this)
