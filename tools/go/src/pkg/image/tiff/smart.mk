#
$(call go-new-module, image/tiff, pkg)

GOFILES=\
	buffer.go\
	compress.go\
	consts.go\
	reader.go\

sm.this.sources := $(GOFILES)
sm.this.depends +=

$(go-build-this)
