#

$(call sm-new-module, foo, gcc: executable)
$(call sm-check-not-empty,sm.this.dir)
#$(call sm-check-not-empty,sm.this.type)
$(call sm-check-not-empty,sm.this.name)
#$(call sm-check-not-empty,sm.this.suffix)
$(call sm-check-not-empty,sm.this.makefile)
#$(call sm-check-in-list,foo,sm.global.modules)
$(call sm-check-equal,$(sm.this.name),foo)
#$(call sm-check-equal,$(sm.this.type),exe)
#$(call sm-check-equal,$(sm.this.toolset),gcc)
$(call sm-check-equal,$(sm.this.suffix),$(if $(sm.os.name.win32),.exe))

sm.this.verbose := false
sm.this.sources := foobar.c
sm.this.compile.flags := -DTEST=\"$(sm.this.name)\"
sm.this.includes := $(sm.this.dir)/../include
sm.this.link.flags := $(if $(sm.os.name.win32),--subsystem=console)
sm.this.libdirs := $(sm.this.dir)/../libs
sm.this.libs := 

$(sm-build-this)
