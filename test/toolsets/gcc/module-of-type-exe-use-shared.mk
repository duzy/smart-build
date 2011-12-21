#
#
####
test.case.module-of-type-exe-use-shared-mk-loaded := 1
####
THIS_MAKEFILE := $(lastword $(MAKEFILE_LIST))
THIS_DIR := $(patsubst %/,%,$(dir $(THIS_MAKEFILE)))
$(call test-check-undefined, sm.this.dir)
$(call sm-new-module, module-of-type-exe-use-shared, gcc: exe)
$(call test-check-value-of,sm.this.dir,$(THIS_DIR))
$(call test-check-value-of,sm.this.makefile,$(THIS_MAKEFILE))
#$(call test-check-value-of,sm.this.suffix,)
$(call test-check-value-of,sm.this.toolset,gcc)
$(call test-check-value-of,sm.this.toolset.args,exe)

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
