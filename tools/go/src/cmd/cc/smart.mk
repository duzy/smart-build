#
$(call go-new-module, cc.a, clib)

sm.this.headers := cc.h
sm.this.sources.c := y.tab.c
sm.this.sources := \
	lex.c\
	mac.c\
	dcl.c\
	acid.c\
	godefs.c\
	bits.c\
	com.c\
	scon.c\
	funct.c\
	sub.c\
	com64.c\
	dpchk.c\
	omachcap.c\
	\
	cc.y

sm.this.includes += $(go.root)/src/cmd/cc

$(sm.this.prefix)/lex.c: $(sm.this.prefix)/y.tab.h

$(go-build-this)
