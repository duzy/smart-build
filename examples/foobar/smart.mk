
my.compile.flags := -O3

my.link.flags := --subsystem=console

foo.o : foobar.c
	$(call sm.tool.gcc.compile.c, $@, $<, my.compile.flags)

foo: foo.o
	$(call sm.tool.gcc.link.c, $@, $<, my.link.flags)

sm.this.toolset := gcc

$(call sm.rule.compile.c, foo/bar/a.o, foobar.c, my.compile.flags)
$(call sm.rule.link.c, foo/bar/a, foo/bar/a.o, my.link.flags)
