#
$(call go-new-module, go/scanner, pkg)

GOFILES=\
	errors.go\
	scanner.go\

sm.this.sources := $(GOFILES)
sm.this.depends += goal-path/filepath

$(go-build-this)
