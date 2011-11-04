#
#	2011-11-04 Duzy Chan <code@duzy.info>
#
$(call test-check-defined,  test.case.smart-config-loaded)
$(call test-check-value-of, test.case.smart-config-loaded,1)

ifneq ($(test.case.smart-config-loaded),1)
  $(error smart.config is not loaded)
endif  # test.case.smart-config-loaded == 1

$(call test-check-defined, sm-new-module)
$(call test-check-flavor,  sm-new-module, recursive)
$(call test-check-value,$(sm.this.name),)
$(call test-check-value,$(sm.this.type),)
########## case in
$(call sm-new-module, foobar, none) ## make a new module
########## case out
$(call test-check-value-of,sm.this.name,foobar)
$(call test-check-value-of,sm.this.type,none)
$(call test-check-value,$(sm.this.toolset),)
$(call test-check-value,$(filter foobar,$(sm.global.modules)),foobar)
# $(call test-check-value-of,sm.module.foobar.name,foobar)
# $(call test-check-value-of,sm.module.foobar.type,none)

test.temp.this-dir := $(sm.this.dir)

$(call test-check-defined, sm-build-this)
$(call test-check-flavor,  sm-build-this, recursive)
########## case in
$(sm-build-this)
########## case out
$(call test-check-value-of,sm.module.foobar.name,foobar)
$(call test-check-value-of,sm.module.foobar.type,none)

$(call test-check-defined, sm.this.dir)
$(call test-check-flavor,  sm-load-module, recursive)
########## case in
$(call sm-load-module, $(sm.this.dir)/another-module.mk)
########## case out
$(call test-check-value-of,test.case.another-module-mk-loaded,1)

$(call test-check-defined, sm.this.dir)
$(call test-check-defined, sm-load-subdirs)
$(call test-check-flavor,  sm-load-subdirs, recursive)
########## case in
$(call sm-load-subdirs, subdirs)
########## case out
$(call test-check-undefined,sm.this.dirs)
$(call test-check-value,$(sm.this.dirs),)
$(call test-check-value-of,test.case.subdirs-loaded,1)
$(call test-check-not-value,$(sm.this.dir),$(test.temp.this-dir))

$(call test-check-undefined,test.case.fake-module-loaded)
########## case in
$(call sm-load-module, $(test.temp.this-dir)/fake-module.mk)
########## case out
$(call test-check-value-of,test.case.fake-module-loaded,1)
$(call test-check-undefined, sm.this.dir)
