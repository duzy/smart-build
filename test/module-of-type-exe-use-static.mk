#
#
####
test.case.module-of-type-exe-use-static-mk-loaded := 1
####
$(call test-check-undefined, sm.this.dir)
$(call sm-new-module, module-of-type-exe-use-static, exe, gcc)
$(call test-check-defined, sm.this.dir)
$(call test-check-value-pat-of,sm.this.dir,%/test)
$(call test-check-value-pat-of,sm.this.makefile,%/test/module-of-type-exe-use-static.mk)
#$(call test-check-value-of,sm.this.suffix,)
$(call test-check-value-of,sm.this.toolset,gcc)

$(call test-check-value-of,sm.module.module-of-type-static.name,module-of-type-static)
$(call test-check-value-of,sm.module.module-of-type-static.export.libs,module-of-type-static)
$(call test-check-value-of,sm.module.module-of-type-static.export.libdirs,$(sm.out.lib))
########## case in
$(call sm-use, module-of-type-static)
########## case out
$(call test-check-value-of,sm.this.using_list,module-of-type-static)

sm.this.sources := main.c

$(call test-check-undefined,sm.module.module-of-type-exe-use-static.used.libs)
$(sm-build-this)
$(call test-check-value,$(strip $(sm.module.module-of-type-exe-use-static.used.libs)),module-of-type-static)
