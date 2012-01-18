#
$(call go-new-module, debug/goym, pkg)

GOFILES=\
	pclntab.go\
	symtab.go\

sm.this.sources := $(GOFILES)
#sm.this.depends += goal-fmt

$(go-build-this)
