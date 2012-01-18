#
$(call go-new-module, strconv, pkg)

GOFILES=\
	atob.go\
	atof.go\
	atoi.go\
	decimal.go\
	extfloat.go\
	ftoa.go\
	itoa.go\
	quote.go\

sm.this.sources := $(GOFILES)

$(go-build-this)
