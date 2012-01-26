#
#
$(call test-check-undefined, sm.this.dir)
$(call test-check-module-empty, sm.this)
$(call test-check-module-empty, sm.module.toolset-gcc-gccgo)
$(call sm-new-module, toolset-gcc-gccgo, gcc: exe)

sm.this.sources := main.go foo.go foo.c
sm.this.sources := $(sm.this.sources:%=../%)

$(sm-build-this)
