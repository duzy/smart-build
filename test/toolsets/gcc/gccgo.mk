#
#
$(call test-check-undefined, sm.this.dir)
$(call sm-new-module, toolset-gcc-gccgo, gcc: exe)

sm.this.sources := main.go foo.go foo.c

$(sm-build-this)
