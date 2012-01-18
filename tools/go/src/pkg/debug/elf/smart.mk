#
$(call go-new-module, debug/elf, pkg)

GOFILES=\
	elf.go\
	file.go\

sm.this.sources := $(GOFILES)
sm.this.depends += goal-fmt

$(go-build-this)
