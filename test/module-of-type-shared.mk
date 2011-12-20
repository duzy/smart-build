#
#
####
test.case.module-of-type-shared-mk-loaded := 1
####
$(call test-check-undefined, sm.this.dir)
########## case in -- make a new module
$(call sm-new-module, module-of-type-shared, gcc: shared)
########## case out
$(call test-check-defined, sm.this.dir)
$(call test-check-value-pat-of,sm.this.dir,%/test)
$(call test-check-value-pat-of,sm.this.makefile,%/test/module-of-type-shared.mk)
#$(call test-check-value-of,sm.this.suffix,.so)

sm.this.sources := foo.c

sofilename := $(sm.out.bin)/$(sm.this.name)$(sm.this.suffix)
sm.this.export.libs := $(sofilename)

$(call test-check-undefined,sm.module.module-of-type-shared.name)
########## case in -- build module
$(sm-build-this)
########## case out
$(call test-check-value-of,sm.module.module-of-type-shared.name,module-of-type-shared)
$(call test-check-value-of,sm.module.module-of-type-shared.export.libs,$(sofilename))
