#
#
####
test.case.module-of-type-exe-use-shared-mk-loaded := 1
####
$(call test-check-undefined, sm.this.dir)
$(call sm-new-module, module-of-type-exe-use-shared, exe, gcc)
$(call test-check-defined, sm.this.dir)
$(call test-check-value-pat-of,sm.this.dir,%/test)
$(call test-check-value-pat-of,sm.this.makefile,%/test/module-of-type-exe-use-shared.mk)
#$(call test-check-value-of,sm.this.suffix,)
$(call test-check-value-of,sm.this.toolset,gcc)

$(call test-check-value-of,sm.module.module-of-type-shared.name,module-of-type-shared)
$(call test-check-value-pat-of,sm.module.module-of-type-shared.export.libs,%/bin/module-of-type-shared.so)
########## case in
$(call sm-use, module-of-type-shared)
########## case out
$(call test-check-value-of,sm.this.using_list,module-of-type-shared)

sm.this.sources := main.c

$(call test-check-undefined,sm.module.module-of-type-exe-use-shared.used.libs)
$(sm-build-this)
$(call test-check-value-pat,$(strip $(sm.module.module-of-type-exe-use-shared.used.libs)),%/bin/module-of-type-shared.so)
