#
$(call go-new-module, debug/elf, pkg)

GOFILES=\
	elf.go\
	file.go\

sm.this.sources := $(GOFILES)

$(go-build-this)
