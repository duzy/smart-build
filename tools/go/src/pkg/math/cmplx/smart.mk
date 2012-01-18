#
$(call go-new-module, math/cmplx, pkg)

GOFILES=\
	abs.go\
	asin.go\
	conj.go\
	exp.go\
	isinf.go\
	isnan.go\
	log.go\
	phase.go\
	polar.go\
	pow.go\
	rect.go\
	sin.go\
	sqrt.go\
	tan.go\

sm.this.sources := $(GOFILES)

$(go-build-this)
