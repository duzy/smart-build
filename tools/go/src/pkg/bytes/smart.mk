#
$(call go-new-module, bytes, pkg)

GOFILES=\
	buffer.go\
	bytes.go\
	bytes_decl.go\

OFILES=\
	asm_$(GOARCH).s\

sm.this.sources := $(GOFILES) $(OFILES)

$(go-build-this)
