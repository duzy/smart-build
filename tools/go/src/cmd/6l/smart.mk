#
$(call go-new-module, 6l, ccmd)

sm.this.sources.c := enam.c
sm.this.sources := \
	../ld/data.c\
	../ld/dwarf.c\
	../ld/elf.c\
	../ld/go.c\
	../ld/ldelf.c\
	../ld/ldmacho.c\
	../ld/ldpe.c\
	../ld/lib.c\
	../ld/macho.c\
	../ld/pe.c\
	../ld/symtab.c\
	asm.c\
	list.c\
	obj.c\
	optab.c\
	pass.c\
	prof.c\
	span.c\
	\
	6.out.h

sm.this.includes += $(go.root)/src/cmd/ld $(go.root)/src/cmd/6l

$(sm.this.prefix)/enam.c: $(sm.this.prefix)/6.out.h
	cd $(@D) &&\
	cp -f $(go.root)/src/cmd/6l/mkenam . &&\
	sh mkenam && [[ -f enam.c ]] && rm -f mkenam

$(sm.this.prefix)/%.h: $(go.root)/src/cmd/6l/%.h
	@test -f $< && test -d $(@D) && mkdir -p $(@D)
	ln -sf $< $@

$(go-build-this)
