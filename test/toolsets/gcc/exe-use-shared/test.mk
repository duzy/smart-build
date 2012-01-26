#
#
####
test.case.exe-use-shared-mk-loaded := 1
####
THIS_MAKEFILE := $(lastword $(MAKEFILE_LIST))
THIS_DIR := $(patsubst %/,%,$(dir $(THIS_MAKEFILE)))
$(call test-check-undefined, sm.this.dir)
$(call test-check-module-empty, sm.this)
$(call test-check-module-empty, sm.module.exe-use-shared)
$(call sm-new-module, exe-use-shared, gcc: exe)
$(call test-check-value-of,sm.this.dir,$(THIS_DIR))
$(call test-check-value-of,sm.this.makefile,$(THIS_MAKEFILE))
#$(call test-check-value-of,sm.this.suffix,)
$(call test-check-value-of,sm.this.toolset,gcc)
$(call test-check-value-of,sm.this.toolset.args,exe)

#$(call sm-use-external, $(this)/../shared)

$(call test-check-value-of,sm.module.gcc-shared.name,gcc-shared)
$(call test-check-value-pat-of,sm.module.gcc-shared.export.libs,%/bin/gcc-shared.so)
########## case in
$(call sm-use, gcc-shared)
########## case out
$(call test-check-value-of,sm.this.using_list,gcc-shared)

sm.this.defines += -DTEST_STR=\"foo\" -DTEST_NUM=10
sm.this.sources := ../main.c

$(call test-check-undefined,sm.module.exe-use-shared.used.libs)
$(sm-build-this)
$(call test-check-value-pat,$(strip $(sm.module.exe-use-shared.used.libs)),%/bin/gcc-shared.so)
