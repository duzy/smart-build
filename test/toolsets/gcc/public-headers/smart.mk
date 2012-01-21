#
#
$(call test-check-undefined, sm.this.dir)
$(call test-check-module-empty, sm.this)
$(call sm-new-module, feature-public-headers, gcc: headers)
$(call test-check-undefined,sm.this.sources)

sm.this.headers.test/gcc := features/foo.h features/bar.h

$(call test-check-undefined,sm.module.feature-public-headers.name)
$(call test-check-undefined,sm.module.feature-public-headers.type)
$(call test-check-undefined,sm.module.feature-public-headers.headers.test/gcc)
$(sm-build-this) ## make rules
$(call test-check-value-of,sm.module.feature-public-headers.name,feature-public-headers)
$(call test-check-value-of,sm.module.feature-public-headers.type,headers)
$(call test-check-value-of,sm.module.feature-public-headers.headers.test/gcc,features/foo.h features/bar.h)
