#
#
####
test.case.module-of-type-exe-use-static-mk-loaded := 1
####
THIS_MAKEFILE := $(lastword $(MAKEFILE_LIST))
THIS_DIR := $(patsubst %/,%,$(dir $(THIS_MAKEFILE)))
$(call test-check-undefined, sm.this.dir)
$(call test-check-module-empty, sm.this)
$(call sm-new-module, module-of-type-exe-use-static, gcc: exe)
$(call test-check-value-of,sm.this.dir,$(THIS_DIR))
$(call test-check-value-of,sm.this.makefile,$(THIS_MAKEFILE))
#$(call test-check-value-of,sm.this.suffix,.exe)
$(call test-check-value-of,sm.this.toolset,gcc)
$(call test-check-value-of,sm.this.toolset.args,exe)

$(call test-check-value-of,sm.module.gcc-static.name,gcc-static)
$(call test-check-value-of,sm.module.gcc-static.export.libs,gcc-static)
$(call test-check-value-of,sm.module.gcc-static.export.libdirs,$(sm.out.lib))
########## case in
$(call sm-use, gcc-static)
########## case out
$(call test-check-value-of,sm.this.using_list,gcc-static)

sm.this.defines += -DTEST_STR=\"foo\" -DTEST_NUM=5
sm.this.sources := main.c

$(call test-check-undefined,sm.module.module-of-type-exe-use-static.used.libs)
$(sm-build-this)
$(call test-check-value,$(strip $(sm.module.module-of-type-exe-use-static.used.libs)),gcc-static)
