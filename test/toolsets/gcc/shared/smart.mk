#
#
####
test.case.module-of-type-shared-mk-loaded := 1
####
THIS_MAKEFILE := $(lastword $(MAKEFILE_LIST))
THIS_DIR := $(patsubst %/,%,$(dir $(THIS_MAKEFILE)))
$(call test-check-undefined, sm.this.dir)
$(call test-check-module-empty, sm.this)
$(call test-check-module-empty, sm.module.module-of-type-shared)
########## case in -- make a new module
$(call sm-new-module, module-of-type-shared, gcc: shared)
########## case out
$(call test-check-value-of,sm.this.dir,$(THIS_DIR))
$(call test-check-value-of,sm.this.makefile,$(THIS_MAKEFILE))
$(call test-check-value-of,sm.this.suffix,.so)
$(call test-check-value-of,sm.this.toolset,gcc)
$(call test-check-value-of,sm.this.toolset.args,shared)

sm.this.sources := foo.c foo.go bar.c
sm.this.compile.flags.c += -DC -fPIC
sm.this.compile.flags-bar.c += -DBAR
sm.this.compile.flags.go += -DG -fPIC

## it looks like gccgo has a bug, we must add -lgcc for symbol "__morestack"
sm.this.libs += -lgcc

sofilename := $(sm.out.bin)/$(sm.this.name)$(sm.this.suffix)
sm.this.export.libs := $(sofilename)

$(call test-check-undefined,sm.module.module-of-type-shared.name)
########## case in -- build module
$(sm-build-this)
########## case out
$(call test-check-value-of,sm.module.module-of-type-shared.name,module-of-type-shared)
$(call test-check-value-of,sm.module.module-of-type-shared.export.libs,$(sofilename))
