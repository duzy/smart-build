foo.o : foobar.c
	$(call sm.tool.gcc.compile.c, $@, $<)

foo: foo.o
	$(call sm.tool.gcc.link.c, $@, $<)

$(call sm.rule.compile.c, foo/bar/a.o, foobar.c)
$(call sm.rule.link.c, foo/bar/a, foo/bar/a.o)
