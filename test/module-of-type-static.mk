#
#
####
test.case.module-of-type-static-mk-loaded := 1
####

$(call test-check-undefined, sm.this.dir)
########## case in -- make a new module
$(call sm-new-module, module-of-type-static, gcc: static)
########## case out
$(call test-check-defined, sm.this.dir)
$(call test-check-value-pat-of,sm.this.dir,%/test)
$(call test-check-value-pat-of,sm.this.makefile,%/test/module-of-type-static.mk)

sm.this.sources := foo.c

sm.this.export.libdirs := $(sm.out.lib)
sm.this.export.libs := $(sm.this.name)

$(call test-check-undefined,sm.module.module-of-type-static.name)
########## case in -- build module
$(sm-build-this)
########## case out
$(call test-check-value-of,sm.module.module-of-type-static.name,module-of-type-static)
