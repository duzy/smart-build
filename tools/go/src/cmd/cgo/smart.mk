#
$(call go-new-module, cgo, cmd)

sm.this.sources := \
	ast.go\
	gcc.go\
	godefs.go\
	main.go\
	out.go\
	util.go\

$(go-build-this)
