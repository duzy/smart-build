# -*- mode: Makefile:gnu -*-
#	Copyright(c) 2009, by Zhan Xin-ming, duzy@duzy.info
#

## This file define rules for objects of C, C++, etc. sources


## Compute sources
$(call sm-var-temp, _suffix.cpp,	:=, %.cpp %.C %.cc %.CC)
$(call sm-var-temp, _suffix.c,		:=, %.c)
$(call sm-var-temp, _suffix.h,		:=, %.h %.hh %.H %.HH)
$(call sm-var-temp, _suffix.asm,	:=, %.s)
$(call sm-var-temp, _sources_rel.cpp,  :=, $(filter $(sm.var.temp._suffix.cpp),$(sm.module.sources)))
$(call sm-var-temp, _sources_rel.c,    :=, $(filter $(sm.var.temp._suffix.c),  $(sm.module.sources)))
$(call sm-var-temp, _sources_rel.h,    :=, $(filter $(sm.var.temp._suffix.h),  $(sm.module.sources)))
$(call sm-var-temp, _sources_rel.asm,  :=, $(filter $(sm.var.temp._suffix.asm),$(sm.module.sources)))
$(call sm-var-temp, _sources_fix.cpp,  :=, $(filter $(sm.var.temp._suffix.cpp),$(sm.module.sources.generated)))
$(call sm-var-temp, _sources_fix.c,    :=, $(filter $(sm.var.temp._suffix.c),  $(sm.module.sources.generated)))
$(call sm-var-temp, _sources_fix.h,    :=, $(filter $(sm.var.temp._suffix.h),  $(sm.module.sources.generated)))
$(call sm-var-temp, _sources_fix.asm,  :=, $(filter $(sm.var.temp._suffix.asm),$(sm.module.sources.generated)))

_sm_has_sources.asm := $(if $(sm.var.temp._sources_fix.asm),true,false)
_sm_has_sources.cpp := $(if $(sm.var.temp._sources_fix.cpp),true,false)
_sm_has_sources.c   := $(if $(sm.var.temp._sources_fix.c),true,false)
_sm_has_sources.h   := $(if $(sm.var.temp._sources_fix.h),true,false)

## Compute include path (-I switches).
$(call sm-var-temp, _includes, :=)
$(foreach v,$(sm.global.dirs.include),\
  $(if $(patsubst -I%,%,$v),$(eval sm.var.temp._includes += -I$$(patsubst -I%,%,$$v))))
$(foreach v,$(sm.module.dirs.include),\
  $(if $(patsubst -I%,%,$v),$(eval sm.var.temp._includes += -I$$(patsubst -I%,%,$$v))))


## Compute compile flages for sources
$(call sm-var-temp, _compile_flags.cpp, :=, $(sm.var.temp._includes))
sm.var.temp._compile_flags.cpp += \
  $(strip $(sm.global.options.compile)) \
  $(strip $(sm.module.options.compile)) \
  $(strip $(sm.module.options.compile.cpp))

$(call sm-var-temp, _compile_flags.c, :=, $(sm.var.temp._includes))
sm.var.temp._compile_flags.c += \
  $(strip $(sm.global.options.compile)) \
  $(strip $(sm.module.options.compile)) \
  $(strip $(sm.module.options.compile.c))

$(call sm-var-temp, _compile_flags.asm, :=, $(sm.var.temp._includes))
sm.var.temp._compile_flags.asm += \
  $(strip $(sm.global.options.compile)) \
  $(strip $(sm.module.options.compile)) \
  $(strip $(sm.module.options.compile.asm))


## The compilation command
$(call sm-var-temp, _compile.cpp, =)
$(call sm-var-temp, _compile.c, =)
$(call sm-var-temp, _compile.asm, =)
sm.var.temp._compile.cpp = $(CXX) -c $(sm.var.temp._compile_flags.cpp) -o $$@ $$<
sm.var.temp._compile.c = $(CC) -c $(sm.var.temp._compile_flags.c) -o $$@ $$<
sm.var.temp._compile.asm = $(AS) $(sm.var.temp._compile_flags.asp) -o $$@ $$<

$(call sm-var-temp, _gen.cpp, =)
$(call sm-var-temp, _gen.c, =)
$(call sm-var-temp, _gen.asm, =)
sm.var.temp._gen.cpp = \
  ( echo "C++: $(sm.module.name) += $$(<:$(sm.dir.top)/%=%)" )\
  && ( $(call _sm_log,$(sm.var.temp._compile.cpp)) )\
  && ( $(sm.var.temp._compile.cpp) || $(call _sm_log,"failed: $$<") )

sm.var.temp._gen.c = \
  ( echo "C: $(sm.module.name) += $$(<:$(sm.dir.top)/%=%)" )\
  && ( $(call _sm_log,$(sm.var.temp._compile.c)) )\
  && ( $(sm.var.temp._compile.c) || $(call _sm_log,"failed: $$<") )

sm.var.temp._gen.asm = \
  ( echo "ASM: $(sm.module.name) += $$(<:$(sm.dir.top)/%=%)" )\
  && ( $(call _sm_log,$(sm.var.temp._compile.asm)) )\
  && ( $(sm.var.temp._compile.asm) || $(call _sm_log,"failed: $$<") )


ifneq ($(sm.module.prebuilt_objects),)
  $(error sm.module.prebuilt_objects is deprecated, use sm.module.objects instead)
  #sm.module.objects := $(sm.module.prebuilt_objects)
endif

#ifeq ($(sm.fun.to-relative),)
ifndef sm.fun.to-relative
  $(error sm.fun.to-relative undefined)
endif

$(call sm-var-temp, _out, :=,$(call sm.fun.to-relative,$(sm.dir.out.obj)))
$(call sm-var-temp, _prefix, :=,$(sm.var.temp._out)$(sm.module.dir:$(sm.dir.top)%=%))
sm.fun.cal-obj = $(sm.var.temp._prefix)/$(subst ..,_,$(basename $(call sm.fun.to-relative,$1)).o)

## Compute objects
$(foreach v,$(sm.module.sources.generated) $(sm.module.sources),\
   $(eval o := $(call sm.fun.cal-obj,$v))\
   $(if $(filter $o,$(sm.module.objects)),,$(eval sm.module.objects += $o)))

## Paths related to sm.dir.top
#sm.module.objects := $(sm.module.objects:$(sm.dir.top)/%=%)

## Prepare output directories
$(foreach v,$(sm.module.objects),$(call sm-util-mkdir,$(dir $v)))

sm.fun.cal-src-fix = $(strip $1)
sm.fun.cal-src-rel = $(sm.module.dir)/$(strip $1)

## Generate rules
define sm.fun.gen-object-rules
$(foreach v,$(sm.var.temp._sources_$2.$1),\
   $(eval o := $(call sm.fun.cal-obj,$v))\
   $(if $(filter $o,$(sm.module.objects.defined)),\
        $(info smart: duplicated $v),\
      $(eval sm.module.objects.defined += $o)\
      $(eval $o : $(call sm.fun.cal-src-$2, $v)\
         ; @$(sm.var.temp._gen.$1))))
endef
$(call sm.fun.gen-object-rules,asm,fix)
$(call sm.fun.gen-object-rules,asm,rel)
$(call sm.fun.gen-object-rules,c,fix)
$(call sm.fun.gen-object-rules,c,rel)
$(call sm.fun.gen-object-rules,cpp,fix)
$(call sm.fun.gen-object-rules,cpp,rel)

#$(info smart: local vars: $(sm.var.temp.*))
$(sm-var-temp-clean)
