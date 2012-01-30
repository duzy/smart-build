#
$(call go-new-module, govet, cmd)

sm.this.sources := \
	main.go\
	method.go\
	print.go\
	structtag.go\

$(go-build-this)
