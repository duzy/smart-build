#
#
####
test.case.module-of-type-none-mk-loaded := 1
####

THIS_MAKEFILE := $(lastword $(MAKEFILE_LIST))
THIS_DIR := $(patsubst %/,%,$(dir $(THIS_MAKEFILE)))
$(call test-check-undefined, sm.this.dir)
$(call test-check-module-empty, sm.this)
########## case in -- make new module
$(call sm-new-module, module-of-type-none, none)
########## case out
$(call test-check-value-of,sm.this.name,module-of-type-none)
$(call test-check-value-of,sm.this.dir,$(THIS_DIR))
$(call test-check-value-of,sm.this.makefile,$(THIS_MAKEFILE))
$(call test-check-value-of,sm.this.type,none)
$(call test-check-value-of,sm.this.toolset,none)
$(call test-check-value,$(sm.this.toolset.args),)

$(call test-check-undefined,sm.module.module-of-type-none.dir)
$(call test-check-undefined,sm.module.module-of-type-none.name)
$(call test-check-undefined,sm.module.module-of-type-none.type)
########## case in -- build module
$(sm-build-this)
########## case out
$(call test-check-value-of,sm.module.module-of-type-none.dir,$(THIS_DIR))
$(call test-check-value-of,sm.module.module-of-type-none.name,module-of-type-none)
$(call test-check-value-of,sm.module.module-of-type-none.type,none)
