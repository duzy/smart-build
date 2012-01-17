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
	macho.h	elf.h\
	obj.h\
	../cmd/8l/8.out.h\
	../cmd/6l/6.out.h\
	../cmd/5l/5.out.h\

sm.this.includes += $(sm.this.dir)
#sm.this.compile.flags-executable.c += -include elf.h

prefix := $(sm.this.dir:$(sm.top)/%=%)
$(prefix)/executable.c: $(prefix)/macho.h $(prefix)/elf.h
$(prefix)/8obj.c: $(prefix)/obj.h\
    $(prefix)/../cmd/8l/8.out.h \
    $(prefix)/../cmd/6l/6.out.h \
    $(prefix)/../cmd/5l/5.out.h \

$(go-build-this)
