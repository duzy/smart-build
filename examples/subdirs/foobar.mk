#

$(call sm-check-empty, sm.this.dir)
$(call sm-new-module, foobar, exe, gcc)

sm.this.verbose := true
sm.this.includes := foo bar
sm.this.sources := foobar.cpp
sm.this.link.flags := -Lfoo -Lbar
sm.this.libdirs := $(sm.out.lib)
sm.this.libs := $(sm.out.bin)/foo.so bar

ifeq ($(sm.os.name),win32)
  sm.this.link.flags := -Wl,--subsystem,console
endif

$(sm-build-this)
