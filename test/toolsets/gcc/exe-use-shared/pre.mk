$(info pre: $(sm-this-makefile))
$(call test-check-value-of,sm.module.gcc-shared.name,gcc-shared)
$(call test-check-value-pat-of,sm.module.gcc-shared.export.libs,%/bin/gcc-shared.so)
