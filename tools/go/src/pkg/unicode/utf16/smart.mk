#
$(call go-new-module, unicode/utf16, pkg)

GOFILES=\
	utf16.go\

sm.this.sources := $(GOFILES)
sm.this.depends += goal-unicode

$(go-build-this)
