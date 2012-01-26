#
$(call go-new-module, compress/flate, pkg)

GOFILES=\
	deflate.go\
	huffman_bit_writer.go\
	huffman_code.go\
	inflate.go\
	reverse_bits.go\
	token.go\

sm.this.sources := $(GOFILES)

$(go-build-this)
