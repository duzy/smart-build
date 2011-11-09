#
#
$(call test-check-undefined, sm.this.dir)
$(call sm-new-module, toolset-gcc-gccgo, exe, gcc)

sm.this.sources := foo.go foo.c

$(sm-build-this)
