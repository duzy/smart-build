#

$(call sm-new-module, foo, shared, gcc)

sm.this.verbose := true
sm.this.sources := foo.cpp
ifeq ($(sm.os.name),win32)
  sm.this.link.options := -Wl,--out-implib,$(sm.out.lib)/libfoo.a
else
  sm.this.depends += $(sm.out.lib)/libfoo.so
  $(sm.out.lib)/libfoo.so : $(sm.out.lib) $(sm.out.bin)/foo.so
	$(call sm.tool.common.ln,$(sm.this.dir)/$(sm.out.bin)/foo.so,$@)
endif
#sm.this.compile.flags := -g
sm.this.depends := foo.txt

foo.txt: ; echo foo > $@

$(sm-build-this)
