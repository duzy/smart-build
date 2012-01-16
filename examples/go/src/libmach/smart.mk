#
$(call go-new-module, mach.a, clib)

sm.this.sources := \
	executable.c\
	fakeobj.c\
	map.c\
	obj.c\
	swap.c\
	sym.c\
	access.c\
	machdata.c\
	setmach.c\
	5.c\
	6.c\
	8.c\
	5db.c\
	8db.c\
	5obj.c\
	6obj.c\
	8obj.c\
	macho.h\
	../cmd/8l/8.out.h\

sm.this.includes += $(sm.this.dir)
#sm.this.compile.flags-executable.c += -include elf.h

$(sm.this.dir:$(sm.top)/%=%)/executable.c: $(sm.this.dir:$(sm.top)/%=%)/macho.h

$(go-build-this)
