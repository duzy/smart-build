#
$(call go-new-module, image/color, pkg)

GOFILES=\
	color.go\
	ycbcr.go\

sm.this.sources := $(GOFILES)

$(go-build-this)
