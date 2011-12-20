#
#
####
test.case.module-of-type-none-mk-loaded := 1
####

$(call test-check-undefined, sm.this.dir)
########## case in -- make new module
$(call sm-new-module, module-of-type-none, none)
########## case out
$(call test-check-defined, sm.this.dir)
$(call test-check-defined, sm.this.makefile)
$(call test-check-value-of,sm.this.name,module-of-type-none)
$(call test-check-value-pat-of,sm.this.dir,%/test)
$(call test-check-value-pat-of,sm.this.makefile,%/test/module-of-type-none.mk)
#$(call test-check-value,$(filter module-of-type-none,$(sm.global.modules)),module-of-type-none)

test.temp.module-of-type-none.dir := $(sm.this.dir)

$(call test-check-undefined,sm.module.module-of-type-none.dir)
$(call test-check-undefined,sm.module.module-of-type-none.name)
$(call test-check-undefined,sm.module.module-of-type-none.type)
########## case in -- build module
$(sm-build-this)
########## case out
$(call test-check-value-of,sm.module.module-of-type-none.dir,$(test.temp.module-of-type-none.dir))
$(call test-check-value-of,sm.module.module-of-type-none.name,module-of-type-none)
$(call test-check-value-of,sm.module.module-of-type-none.type,none)
