#
$(call go-new-module, go/build, pkg)

GOFILES=\
	build.go\
	dir.go\
	path.go\
	syslist.go\

sm.this.sources := $(GOFILES)
sm.this.depends += goal-regexp goal-log

$(go-build-this)
