#
$(call go-new-module, image/jpeg, pkg)

GOFILES=\
	fdct.go\
	huffman.go\
	idct.go\
	reader.go\
	writer.go\

sm.this.sources := $(GOFILES)
sm.this.depends +=

$(go-build-this)
