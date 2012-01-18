#
$(call go-new-module, cgo, cmd)
#$(call sm-use, fmt)

sm.this.sources := \
	ast.go\
	gcc.go\
	godefs.go\
	main.go\
	out.go\
	util.go\

$(go-build-this)
