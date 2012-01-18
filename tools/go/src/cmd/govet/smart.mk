#
$(call go-new-module, govet, cmd)

sm.this.sources := \
	govet.go\
	method.go\
	print.go\
	structtag.go\

$(go-build-this)
