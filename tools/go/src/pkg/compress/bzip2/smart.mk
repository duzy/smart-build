#
$(call go-new-module, compress/bzip2, pkg)

GOFILES=\
	bit_reader.go\
	bzip2.go\
	huffman.go\
	move_to_front.go\

sm.this.sources := $(GOFILES)

$(go-build-this)
