#
$(call go-new-module, goyacc, cmd)

sm.this.sources := \
	yacc.go\

$(go-build-this)
