#
$(call go-new-module, math, pkg)

OFILES=\
	abs_$(GOARCH).s\
	asin_$(GOARCH).s\
	atan_$(GOARCH).s\
	atan2_$(GOARCH).s\
	dim_$(GOARCH).s\
	exp_$(GOARCH).s\
	exp2_$(GOARCH).s\
	expm1_$(GOARCH).s\
	floor_$(GOARCH).s\
	frexp_$(GOARCH).s\
	hypot_$(GOARCH).s\
	ldexp_$(GOARCH).s\
	log_$(GOARCH).s\
	log10_$(GOARCH).s\
	log1p_$(GOARCH).s\
	mod_$(GOARCH).s\
	modf_$(GOARCH).s\
	remainder_$(GOARCH).s\
	sin_$(GOARCH).s\
	sincos_$(GOARCH).s\
	sqrt_$(GOARCH).s\
	tan_$(GOARCH).s\

GOFILES=\
	abs.go\
	acosh.go\
	asin.go\
	asinh.go\
	atan.go\
	atanh.go\
	atan2.go\
	bits.go\
	cbrt.go\
	const.go\
	copysign.go\
	dim.go\
	erf.go\
	exp.go\
	expm1.go\
	floor.go\
	frexp.go\
	gamma.go\
	hypot.go\
	j0.go\
	j1.go\
	jn.go\
	lgamma.go\
	ldexp.go\
	log.go\
	log10.go\
	log1p.go\
	logb.go\
	mod.go\
	modf.go\
	nextafter.go\
	pow.go\
	pow10.go\
	remainder.go\
	signbit.go\
	sin.go\
	sincos.go\
	sinh.go\
	sqrt.go\
	tan.go\
	tanh.go\
	unsafe.go\

sm.this.sources := $(GOFILES) $(OFILES)

$(go-build-this)