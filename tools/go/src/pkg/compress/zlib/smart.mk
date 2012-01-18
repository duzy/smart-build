#
$(call go-new-module, compress/zlib, pkg)

GOFILES=\
	reader.go\
	writer.go\

sm.this.sources := $(GOFILES)
sm.this.depends += goal-hash/adler32

$(go-build-this)
