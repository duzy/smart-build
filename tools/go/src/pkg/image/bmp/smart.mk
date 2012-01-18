#
$(call go-new-module, image/bmp, pkg)

GOFILES=\
	reader.go\

sm.this.sources := $(GOFILES)
sm.this.depends += goal-image/color

$(go-build-this)
