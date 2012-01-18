#
$(call go-new-module, bytes, pkg)

GOFILES=\
	buffer.go\
	bytes.go\
	bytes_decl.go\

OFILES=\
	asm_$(GOARCH).s\

sm.this.sources := $(GOFILES) $(OFILES)
sm.this.depends += goal-unicode/utf8

$(go-build-this)
