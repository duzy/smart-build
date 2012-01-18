#
$(call go-new-module, goyacc, cmd)

sm.this.sources := \
	goyacc.go\

$(go-build-this)
