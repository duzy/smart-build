#
$(call go-new-module, image/gif, pkg)

GOFILES=\
	reader.go\

sm.this.sources := $(GOFILES)
sm.this.depends += goal-image/color

$(go-build-this)
