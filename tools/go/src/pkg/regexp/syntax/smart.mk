#
$(call go-new-module, regexp/syntax, pkg)

GOFILES=\
	compile.go\
	parse.go\
	perl_groups.go\
	prog.go\
	regexp.go\
	simplify.go\

sm.this.sources := $(GOFILES)

$(go-build-this)
