#
$(call go-new-module, 6l, ccmd)

sm.this.sources := \
	asm.c\
	../ld/data.c\
	../ld/dwarf.c\
	../ld/elf.c\
	enam.c\
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

sm.this.includes += $(go.root)/src/cmd/ld $(go.root)/src/cmd/6l

$(go-build-this)
