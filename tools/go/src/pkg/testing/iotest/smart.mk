#
$(call go-new-module, testing/iotest, pkg)

GOFILES=\
	logger.go\
	reader.go\
	writer.go\

sm.this.sources := $(GOFILES)

$(go-build-this)
