#
$(call go-new-module, 6c, ccmd)
$(call sm-use, cc)

sm.this.sources.c := ../6l/enam.c
sm.this.sources := \
	cgen.c\
	list.c\
	sgen.c\
	swt.c\
	txt.c\
	div.c\
	mul.c\
	reg.c\
	peep.c\
	machcap.c\
	../cc/pgen.c\
	../cc/pswt.c\

sm.this.includes += $(go.root)/src/cmd/6c

$(prefix)/../6l/enam.c: $(dir $(prefix))6l/enam.c

$(go-build-this)
