#
$(call go-new-module, regexp, pkg)

GOFILES=\
	exec.go\
	regexp.go\

sm.this.sources := $(GOFILES)
sm.this.depends += goal-regexp/syntax

$(go-build-this)
