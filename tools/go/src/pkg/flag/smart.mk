#
$(call go-new-module, flag, pkg)

GOFILES=\
	flag.go\

sm.this.sources := $(GOFILES)
sm.this.depends += goal-sort

$(go-build-this)
