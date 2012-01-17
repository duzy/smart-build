#
$(call go-new-module, gc.a, clib)

sm.this.sources.c := builtin.c y1.tab.c
sm.this.sources := \
	align.c\
	bits.c\
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
	\
	go.y\

GOEXPERIMENT := 
sm.this.defines += -DGOEXPERIMENT='"$(GOEXPERIMENT)"'
sm.this.includes += $(go.root)/src/cmd/gc

prefix := $(sm.this.dir:$(sm.top)/%=%)
$(prefix)/builtin.c: $(go.root)/src/cmd/gc/builtin.c.boot ; ln -sf $< $@
$(prefix)/y1.tab.c: $(prefix)/y.tab.c
	cat $< | sed '/ int yystate;/d; s/int yychar;/int yychar, yystate;/; s/static const char \*const yytname/const char *yytname/; s/char const \*yymsgp/char *yymsgp/' > $@
$(prefix)/subr.c: $(prefix)/yerr.h
$(prefix)/yerr.h: $(go.root)/src/cmd/gc/bisonerrors $(go.root)/src/cmd/gc/go.errors \
    $(prefix)/y.tab.h
	cd $(@D) &&\
	cp -f $(go.root)/src/cmd/gc/bisonerrors . &&\
	cp -f $(go.root)/src/cmd/gc/go.errors . &&\
	awk -f bisonerrors y.output go.errors > yerr.h

$(go-build-this)
