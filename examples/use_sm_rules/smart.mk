
my.compile.flags := -O3

my.link.flags := $(if $(sm.os.name.win32),--subsystem=console)

foo.o : foobar.c
	@echo using sm.tool.gcc.compile.c for $@ 
	$(call sm.tool.gcc.compile.c, $@, $<, my.compile.flags)

foo: foo.o
	@echo using sm.tool.gcc.link.c for $@ 
	$(call sm.tool.gcc.link.c, $@, $<, my.link.flags)

clean-all:
	@rm -vf foo foo.o

# sm.rule.* require sm.this.toolset to be set
sm.this.toolset := gcc

sm.this.clean-steps := clean-all

$(call sm.rule.compile.c, foo/bar/a.o, foobar.c, my.compile.flags)
$(call sm.rule.link.c, foo/bar/a, foo/bar/a.o, , my.link.flags)

# TODO: refactore sm.rule.link.c for better usage
