#
#
$(call test-check-module-empty, sm.this)
$(call test-check-module-empty, sm.module.toolset_go_package)
$(call sm-new-module, toolset_go_package, go: package)

sm.this.sources := foo.go foo.c
sm.this.export.includes := $(sm.out.pkg)
sm.this.export.libdirs := $(sm.out.pkg)

$(sm-build-this)
