# -*- mode: Makefile:gnu -*-
#	Copyright(c) 2009, by Zhan Xin-ming, duzy@duzy.info
#	

## This file is expected to be included BEFORE including an 'smart.mk'(module).

sm.log.filename :=
# sm.module.depends :=
# sm.module.dir :=
# sm.module.dirs.include :=
# sm.module.dirs.lib :=
# sm.module.headers :=
# sm.module.libs :=
# sm.module.name :=
# sm.module.options.compile :=
# sm.module.options.link :=
# sm.module.out_implib :=
# sm.module.sources :=
# sm.module.suffix :=
# sm.module.type :=
# sm.module.whole_archives :=

ifeq ($(strip $(sm.module.*)),)
  $(error smart: Variable 'sm.module.*' must be defined!)
endif

$(foreach v,$(sm.module.*),$(eval sm.module.$v:=))

ifneq ($(sm.module.name),)
  $(error smart: Variable 'sm.module.name' is not reset!)
endif
