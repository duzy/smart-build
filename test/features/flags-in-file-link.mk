#
#
$(call test-check-undefined, sm.this.dir)
$(call sm-new-module, feature-flags-in-file-link, exe, gcc)

sm.this.compile.flags := -DTEST=\"$(sm.this.name)\"
sm.this.sources := main.c

sm.this.link.flags.infile := yes
sm.this.link.flags := $(if $(sm.os.name.win32),--subsystem=console)
sm.this.link.flags += -O2

$(sm-build-this)
