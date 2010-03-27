# -*- mode: Makefile:gnu -*-
#	Copyright(c) 2009, by Zhan Xin-ming, duzy@duzy.info
#

## This file define rules for objects of C, C++, etc. sources


## Compute sources
$(call sm-var-local, _suffix.cpp,	:=, %.cpp %.C %.cc %.CC)
$(call sm-var-local, _suffix.c,		:=, %.c)
$(call sm-var-local, _suffix.h,		:=, %.h %.hh %.H %.HH)
$(call sm-var-local, _suffix.asm,	:=, %.s)
$(call sm-var-local, _sources_rel.cpp,  :=, $(filter $(sm.var.local._suffix.cpp),$(sm.module.sources)))
$(call sm-var-local, _sources_rel.c,    :=, $(filter $(sm.var.local._suffix.c),  $(sm.module.sources)))
$(call sm-var-local, _sources_rel.h,    :=, $(filter $(sm.var.local._suffix.h),  $(sm.module.sources)))
$(call sm-var-local, _sources_rel.asm,  :=, $(filter $(sm.var.local._suffix.asm),$(sm.module.sources)))
$(call sm-var-local, _sources_fix.cpp,  :=, $(filter $(sm.var.local._suffix.cpp),$(sm.module.sources.generated)))
$(call sm-var-local, _sources_fix.c,    :=, $(filter $(sm.var.local._suffix.c),  $(sm.module.sources.generated)))
$(call sm-var-local, _sources_fix.h,    :=, $(filter $(sm.var.local._suffix.h),  $(sm.module.sources.generated)))
$(call sm-var-local, _sources_fix.asm,  :=, $(filter $(sm.var.local._suffix.asm),$(sm.module.sources.generated)))

## Compute include path (-I switches).
$(call sm-var-local, _includes, :=)
$(foreach v,$(sm.global.dirs.include),\
  $(if $(patsubst -I%,%,$v),$(eval sm.var.local._includes += -I$$(patsubst -I%,%,$$v))))
$(foreach v,$(sm.module.dirs.include),\
  $(if $(patsubst -I%,%,$v),$(eval sm.var.local._includes += -I$$(patsubst -I%,%,$$v))))


## Compute compile flages for sources
$(call sm-var-local, _compile_flags.cpp, :=, $(sm.var.local._includes))
sm.var.local._compile_flags.cpp += \
  $(strip $(sm.global.options.compile)) \
  $(strip $(sm.module.options.compile)) \
  $(strip $(sm.module.options.compile.cpp))

$(call sm-var-local, _compile_flags.c, :=, $(sm.var.local._includes))
sm.var.local._compile_flags.c += \
  $(strip $(sm.global.options.compile)) \
  $(strip $(sm.module.options.compile)) \
  $(strip $(sm.module.options.compile.c))


## The compilation command
$(call sm-var-local, _compile.cpp, =)
$(call sm-var-local, _compile.c, =)
sm.var.local._compile.cpp = $(CXX) -c $(sm.var.local._compile_flags.cpp) -o $$@ $$<
sm.var.local._compile.c = $(CC) -c $(sm.var.local._compile_flags.c) -o $$@ $$<

$(call sm-var-local, _gen.cpp, =)
$(call sm-var-local, _gen.c, =)
$(call sm-var-local, _gen.asm, =)
sm.var.local._gen.cpp = \
  ( echo "C++: $(sm.module.name) += $$(<:$(sm.dir.top)/%=%)" )\
  && ( $(call _sm_log,$(sm.var.local._compile.cpp)) )\
  && ( $(sm.var.local._compile.cpp) || $(call _sm_log,"failed: $$<") )

sm.var.local._gen.c = \
  ( echo "C: $(sm.module.name) += $$(<:$(sm.dir.top)/%=%)" )\
  && ( $(call _sm_log,$(sm.var.local._compile.c)) )\
  && ( $(sm.var.local._compile.c) || $(call _sm_log,"failed: $$<") )

sm.var.local._gen.asm = \
  ( echo "ASM: todo: $(sm.module.name) += $$(<:$(sm.dir.top)/%=%)" )


ifneq ($(sm.module.prebuilt_objects),)
  $(error sm.module.prebuilt_objects is deprecated, use sm.module.objects instead)
endif

#sm.module.objects := $(sm.module.prebuilt_objects)


$(call sm-var-local, _prefix, :=,$(sm.dir.out.obj)$(sm.module.dir:$(sm.dir.top)%=%))
sm.fun.cal-obj = $(sm.var.local._prefix)/$(subst ..,_,$(basename $1).o)

## Compute objects
$(foreach v,$(sm.module.sources.generated) $(sm.module.sources),\
   $(eval sm.module.objects += $(call sm.fun.cal-obj,$v)))


## Prepare output directories
$(foreach v,$(sm.module.objects),\
   $(call _sm_mk_out_dir,$(dir $v)))

sm.fun.cal-src-fix = $(strip $1)
sm.fun.cal-src-rel = $(sm.module.dir)/$(strip $1)

## Generate rules
define sm.fun.gen-object-rules
$(foreach v,$(sm.var.local._sources_$2.$1),\
   $(eval $(call sm.fun.cal-obj,$v)\
      : $(call sm.fun.cal-src-$2, $v)\
      ; @$(sm.var.local._gen.$1)))
endef
$(call sm.fun.gen-object-rules,asm,fix)
$(call sm.fun.gen-object-rules,asm,rel)
$(call sm.fun.gen-object-rules,c,fix)
$(call sm.fun.gen-object-rules,c,rel)
$(call sm.fun.gen-object-rules,cpp,fix)
$(call sm.fun.gen-object-rules,cpp,rel)

#$(info smart: local vars: $(sm.var.local.*))
$(sm-var-local-clean)
