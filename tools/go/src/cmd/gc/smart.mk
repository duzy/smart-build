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
	go.h\
	go.y\

GOEXPERIMENT := 
sm.this.defines += -DGOEXPERIMENT='"$(GOEXPERIMENT)"'
sm.this.includes += $(go.root)/src/cmd/gc

$(sm.this.prefix)/y1.tab.c: $(sm.this.prefix)/y.tab.c
	cat $< | sed '/ int yystate;/d; s/int yychar;/int yychar, yystate;/; s/static const char \*const yytname/const char *yytname/; s/char const \*yymsgp/char *yymsgp/' > $@
$(sm.this.prefix)/subr.c: $(sm.this.prefix)/yerr.h
$(sm.this.prefix)/yerr.h: $(sm.this.prefix)/y.tab.h \
    $(go.root)/src/cmd/gc/bisonerrors $(go.root)/src/cmd/gc/go.errors
	cd $(@D) &&\
	cp -f $(go.root)/src/cmd/gc/bisonerrors . &&\
	cp -f $(go.root)/src/cmd/gc/go.errors . &&\
	awk -f bisonerrors y.output go.errors > yerr.h &&\
	( rm -f bisonerrors go.errors )	|| ( rm -f yerr.h && false )
$(sm.this.prefix)/fmt.c: $(sm.this.prefix)/opnames.h
$(sm.this.prefix)/opnames.h: $(sm.this.prefix)/mkopnames $(sm.this.prefix)/go.h
	cd $(@D) && ./mkopnames go.h > opnames.h
$(sm.this.prefix)/builtin.c: $(go.root)/src/cmd/gc/builtin.c.boot
	ln -sf $< $@
$(sm.this.prefix)/mkopnames: $(go.root)/src/cmd/gc/mkopnames
	ln -sf $< $@

$(go-build-this)
