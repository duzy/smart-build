#
$(call go-new-module, runtime, pkg)

sm.this.sources := \
	debug.go\
	error.go\
	extern.go\
	mem.go\
	sig.go\
	softfloat64.go\
	type.go\
	zgoarch_$(GOARCH).go\
	zgoos_$(GOOS).go\
	zruntime_defs_$(GOOS)_$(GOARCH).go\
	zversion.go\

$(go-build-this)
