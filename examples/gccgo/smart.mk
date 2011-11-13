#

$(call sm-new-module, foo, executable, gcc)

sm.this.verbose := true
sm.this.sources := foo.go bar.c
sm.this.compile.flags :=
sm.this.includes :=
sm.this.link.flags :=
sm.this.libdirs :=
sm.this.libs := 

$(sm-build-this)
