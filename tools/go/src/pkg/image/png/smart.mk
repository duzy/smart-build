#
$(call go-new-module, image/png, pkg)

GOFILES=\
	reader.go\
	writer.go\

sm.this.sources := $(GOFILES)
sm.this.depends +=

$(go-build-this)
