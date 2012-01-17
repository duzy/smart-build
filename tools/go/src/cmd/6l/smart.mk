#
$(call go-new-module, 6l, ccmd)

sm.this.sources.c := enam.c
sm.this.sources := \
	asm.c\
	../ld/data.c\
	../ld/dwarf.c\
	../ld/elf.c\
	../ld/go.c\
	../ld/ldelf.c\
	../ld/ldmacho.c\
	../ld/ldpe.c\
	../ld/lib.c\
	list.c\
	../ld/macho.c\
	obj.c\
	optab.c\
	pass.c\
	../ld/pe.c\
	prof.c\
	span.c\
	../ld/symtab.c\
	\
	6.out.h

sm.this.includes += $(go.root)/src/cmd/ld $(go.root)/src/cmd/6l

$(sm.this.dir:$(sm.top)/%=%)/enam.c: $(sm.this.dir:$(sm.top)/%=%)/6.out.h
	cd $(@D) && cp -f $(go.root)/src/cmd/6l/mkenam . &&\
	sh mkenam && [[ -f enam.c ]] && rm -f mkenam

$(go-build-this)
