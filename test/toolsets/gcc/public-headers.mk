#
#
$(call test-check-undefined, sm.this.dir)
$(foreach _, $(filter sm.this.headers.%,$(.VARIABLES)),\
             $(call test-check-undefined,$_))
$(call sm-new-module, feature-public-headers, none: depends)

sm.this.headers.test/features := foo.h bar.h

$(call test-check-undefined,sm.module.feature-public-headers.name)
$(call test-check-undefined,sm.module.feature-public-headers.type)
$(call test-check-undefined,sm.module.feature-public-headers.headers.test/features)
$(sm-build-this) ## make rules
$(call test-check-value-of,sm.module.feature-public-headers.name,feature-public-headers)
$(call test-check-value-of,sm.module.feature-public-headers.type,none)
$(call test-check-value-of,sm.module.feature-public-headers.headers.test/features,foo.h bar.h)
