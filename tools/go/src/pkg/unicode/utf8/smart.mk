#
$(call go-new-module, unicode/utf8, pkg)

GOFILES=\
	utf8.go\

sm.this.sources := $(GOFILES)
sm.this.depends += goal-unicode

$(go-build-this)
