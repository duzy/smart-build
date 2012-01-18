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
sm.this.depends += goal-bytes goal-strings

$(go-build-this)
