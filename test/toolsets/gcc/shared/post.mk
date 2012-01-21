$(info post: $(sm-this-makefile))
$(call test-check-value-of,sm.module.gcc-shared.name,gcc-shared)
$(call test-check-value-of,sm.module.gcc-shared.export.libs,$(sofilename))
