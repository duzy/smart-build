#
$(call go-new-module, 6g, ccmd)
$(call sm-use, gc)

sm.this.sources.c := ../6l/enam.c
sm.this.sources := \
	cgen.c\
	../gc/cplx.c\
	galign.c\
	ggen.c\
	gobj.c\
	gsubr.c\
	list.c\
	peep.c\
	../gc/pgen.c\
	reg.c\

sm.this.includes += $(go.root)/src/cmd/6g $(go.root)/src/cmd/gc

$(prefix)/../6l/enam.c: $(dir $(prefix))6l/enam.c

$(go-build-this)
