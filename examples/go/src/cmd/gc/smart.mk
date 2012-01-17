#
$(call go-new-module, gc.a, clib)

sm.this.sources := \
	align.c\
	bits.c\
	builtin.c\
	closure.c\
	const.c\
	dcl.c\
	esc.c\
	export.c\
	fmt.c\
	gen.c\
	init.c\
	inl.c\
	lex.c\
	md5.c\
	mparith1.c\
	mparith2.c\
	mparith3.c\
	obj.c\
	range.c\
	reflect.c\
	select.c\
	sinit.c\
	subr.c\
	swt.c\
	typecheck.c\
	unsafe.c\
	walk.c\
	y1.tab.c\

GOEXPERIMENT := 
sm.this.defines += -DGOEXPERIMENT='"$(GOEXPERIMENT)"'
sm.this.includes += $(go.root)/src/cmd/gc

$(go-build-this)
