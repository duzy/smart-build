#
$(call go-new-module, image, pkg)

GOFILES=\
	format.go\
	geom.go\
	image.go\
	names.go\
	ycbcr.go\

sm.this.sources := $(GOFILES)
sm.this.depends += goal-image/color

$(go-build-this)
