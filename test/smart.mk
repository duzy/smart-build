#
#	2011-11-04 Duzy Chan <code@duzy.info>
#
include main.mk

define check-recursive
$(eval \
  ifneq ($(flavor $_),recursive)
    $$(error "$_" is not recursive: $(flavor $_))
  endif
 )
endef #check-recursive
$(foreach _,\
  test-check-defined\
  test-check-flavor\
  test-check-origin\
  test-check-value-of\
  test-check-value\
  test-check-undefined\
  test-check-value-pat\
  ,$(check-recursive))

THIS_MAKEFILE := $(lastword $(MAKEFILE_LIST))
test.temp.this-dir := $(patsubst %/,%,$(dir $(THIS_MAKEFILE)))
$(call test-check-defined,  test.case.smart-config-loaded)
$(call test-check-value-of, test.case.smart-config-loaded,1)

ifneq ($(test.case.smart-config-loaded),1)
  $(error smart.config is not loaded)
endif  # test.case.smart-config-loaded == 1

$(call test-check-defined, SMART)
$(call test-check-defined, SMARTROOT)
$(call test-check-flavor, SMART, recursive)
$(call test-check-flavor, SMARTROOT, recursive)
$(call test-check-origin, SMART, environment)
$(call test-check-origin, SMARTROOT, environment)

$(call test-check-defined, sm-new-module)
$(call test-check-flavor,  sm-new-module, recursive)
$(call test-check-value,$(sm.this.name),)
$(call test-check-value,$(sm.this.type),)
########## case in -- new module
$(call sm-new-module, foobar, none) ## make a new module
########## case out
$(call test-check-value-of,sm.this.name,foobar)
$(call test-check-value-of,sm.this.type,none)
$(call test-check-value,$(sm.this.toolset),none)
#$(call test-check-value,$(filter foobar,$(sm.global.modules)),foobar)
#$(call test-check-value-of,sm.module.foobar.name,foobar)
#$(call test-check-value-of,sm.module.foobar.type,none)

$(call test-check-value,$(test.temp.this-dir),$(sm.this.dir))

$(call test-check-defined, sm-build-this)
$(call test-check-flavor,  sm-build-this, recursive)
########## case in -- build module
$(sm-build-this)
########## case out
$(call test-check-value-of,sm.module.foobar.name,foobar)
$(call test-check-value-of,sm.module.foobar.type,none)

# $(call test-check-defined, sm.this.dir)
# $(call test-check-flavor,  sm-load-module, recursive)
# ########## case in  -- load a single module
# $(call sm-load-module, $(sm.this.dir)/module-of-type-none/smart.mk)
# ########## case out
# $(call test-check-value-of,test.case.module-of-type-none-mk-loaded,1)

##################################################

$(call test-check-defined, sm.this.dir) ## defined by last loaded module
$(call test-check-defined, sm-load-subdirs)
$(call test-check-flavor,  sm-load-subdirs, recursive)
########## case in -- load module in sub-directories
$(call sm-load-subdirs, subdirs subdir)
########## case out
$(call test-check-undefined,sm.this.dirs)
$(call test-check-value,$(sm.this.dirs),)
$(call test-check-value-of,test.case.subdirs-loaded,1)
$(call test-check-value-of,test.case.subdir-loaded,1)
$(call test-check-not-value,$(sm.this.dir),$(test.temp.this-dir))
$(call test-check-defined,sm.this.dir) ## should not be empty
$(call test-check-value-of,sm.this.dir,subdir)
$(call test-check-defined, sm.module.subdir-foo.name)
$(call test-check-defined, sm.module.subdir-foo.type)
$(call test-check-defined, sm.module.subdir-foo.dir)
$(call test-check-value-of,sm.module.subdir-foo.name,subdir-foo)
$(call test-check-value-of,sm.module.subdir-foo.type,none)
$(call test-check-value-of,sm.module.subdir-foo.dir,subdir)

# $(call test-check-undefined,test.case.module-nothing-loaded)
# ########## case in
# $(call sm-load-module, $(test.temp.this-dir)/module-nothing.mk)
# ########## case out
# $(call test-check-value-of,test.case.module-nothing-loaded,1)
# $(call test-check-undefined, sm.this.dir) ## fake-module make nothing, sm-load-module unset this

##################################################
define check-module
$(call test-check-flavor, sm-load-module, recursive)\
$(eval module.pre := $(wildcard $(module:%/smart.mk=%.pre)))\
$(eval #
  ifdef module.pre
    PRE :=
    LOCAL := $(patsubst %/,%,$(dir $(module.pre)))
    include $(module.pre)
    #$$(info test: preload "$$(PRE)" for "$(module)")
    ifdef PRE
      $$(call sm-load-module, $$(PRE))
      modules.loaded += $$(PRE)
    endif
  endif
 )\
$(if $(filter $(module), $(modules.loaded))\
    ,,$(call sm-load-module, $(module))\
      $(eval modules.loaded += $(module)))
endef #check-module

modules.loaded :=
modules := \
  $(wildcard $(test.temp.this-dir)/features/*/smart.mk) \
  $(wildcard $(test.temp.this-dir)/toolsets/*/smart.mk) \
  $(wildcard $(test.temp.this-dir)/toolsets/*/*/smart.mk) \
  $(wildcard $(test.temp.this-dir)/toolsets/*/*/*/smart.mk)
$(foreach module, $(modules), $(check-module))
