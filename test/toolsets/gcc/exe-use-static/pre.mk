$(call test-check-value-of,sm.module.gcc-static.name,gcc-static)
$(call test-check-value-of,sm.module.gcc-static.export.libs,gcc-static)
$(call test-check-value-of,sm.module.gcc-static.export.libdirs,$(sm.out.lib))
