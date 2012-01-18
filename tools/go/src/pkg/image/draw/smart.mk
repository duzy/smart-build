#
$(call go-new-module, image/draw, pkg)

GOFILES=\
	draw.go\

sm.this.sources := $(GOFILES)
sm.this.depends += goal-image/color

$(go-build-this)
