#

$(call sm-check-empty, sm.this.dir)
$(call sm-new-module, foobar, exe)

sm.this.verbose := true
sm.this.toolset := gcc
sm.this.includes := foo bar
sm.this.sources := foobar.cpp
sm.this.link.options := -Lfoo -Lbar
sm.this.libdirs := $(sm.out.lib)
sm.this.libs := foo bar

ifeq ($(sm.os.name),win32)
  sm.this.link.options := -Wl,--subsystem,console
endif

$(sm-build-this)
