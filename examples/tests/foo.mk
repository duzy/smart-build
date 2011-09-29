##################################################

$(call sm-new-module, foo, tests, gcc)
sm.this.verbose := true
sm.this.lang := c
sm.this.toolset := gcc
sm.this.sources := foo.t
sm.this.compile.flags := -DTEST=\"$(sm.this.name)\"
sm.this.includes := $(sm.this.dir)/../include
sm.this.link.flags := $(if $(sm.os.name.win32),--subsystem=console)
sm.this.libdirs := $(sm.this.dir)/../libs
sm.this.libs := 
$(sm-build-this)
