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

##################################################
define test-load-module
$(if $(filter $1, $(modules.loaded)),,\
 $(eval #
   pre  := $(dir $1)pre.mk
   post := $(dir $1)post.mk
  )\
 $(eval #
   $(if $(wildcard $(pre)),  include $(pre))

   $(call test-check-flavor, sm-load-module, recursive)
   $$(call sm-load-module, $1)
   modules.loaded += $1

   $(if $(wildcard $(post)), include $(post))
  )\
 $(eval #
   pre  :=
   post :=
  ))
endef #test-load-module

define check-module
$(eval #
  module.pre := $(wildcard $(module:%/smart.mk=%.pre))
  PRE :=
  LOCAL :=
 )\
$(eval #
  ifdef module.pre
    LOCAL := $(patsubst %/,%,$(dir $(module.pre)))
    include $(module.pre)
    ifdef PRE
      $$(call test-load-module, $$(PRE))
    endif
  endif
 )\
$(call test-load-module, $(module))
endef #check-module

modules.loaded :=
modules := $(shell find . -type f -name 'smart.mk' -and ! -regex "./subdir.*")
modules := $(filter-out smart.mk, $(modules:./%=%))
$(foreach module, $(modules), $(check-module))
