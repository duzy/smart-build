# -*- mode: Makefile:gnu -*-
#	Copyright(c) 2009, by Zhan Xin-ming, duzy@duzy.info
#

## This file define rules for objects of C, C++, etc. sources


## Compute sources
$(call sm-var-temp, _suffix.c++,       :=, %.cpp %.c++ %.C %.cc %.CC)
$(call sm-var-temp, _suffix.c,         :=, %.c)
$(call sm-var-temp, _suffix.h,         :=, %.h %.hh %.H %.HH)
$(call sm-var-temp, _suffix.t,         :=, %.t)
$(call sm-var-temp, _suffix.asm,       :=, %.s)
$(call sm-var-temp, _sources_fix.asm,  :=, $(filter $(sm.var.temp._suffix.asm),$(sm.module.sources.generated)))
$(call sm-var-temp, _sources_fix.c,    :=, $(filter $(sm.var.temp._suffix.c),  $(sm.module.sources.generated)))
$(call sm-var-temp, _sources_fix.c++,  :=, $(filter $(sm.var.temp._suffix.c++),$(sm.module.sources.generated)))
$(call sm-var-temp, _sources_fix.h,    :=, $(filter $(sm.var.temp._suffix.h),  $(sm.module.sources.generated)))
$(call sm-var-temp, _sources_fix.t,    :=, $(filter $(sm.var.temp._suffix.t),  $(sm.module.sources.generated)))
$(call sm-var-temp, _sources_fix,      :=, $(sm.var.temp._sources_fix.c) $(sm.var.temp._sources_fix.c++) $(sm.var.temp._sources_fix.asm) $(sm.var.temp._sources_fix.t))
$(call sm-var-temp, _sources_rel.asm,  :=, $(filter $(sm.var.temp._suffix.asm),$(sm.module.sources)))
$(call sm-var-temp, _sources_rel.c,    :=, $(filter $(sm.var.temp._suffix.c),  $(sm.module.sources)))
$(call sm-var-temp, _sources_rel.c++,  :=, $(filter $(sm.var.temp._suffix.c++),$(sm.module.sources)))
$(call sm-var-temp, _sources_rel.h,    :=, $(filter $(sm.var.temp._suffix.h),  $(sm.module.sources)))
$(call sm-var-temp, _sources_rel.t,    :=, $(filter $(sm.var.temp._suffix.t),  $(sm.module.sources)))
$(call sm-var-temp, _sources_rel,      :=, $(sm.var.temp._sources_rel.c) $(sm.var.temp._sources_rel.c++) $(sm.var.temp._sources_rel.asm) $(sm.var.temp._sources_rel.t))
$(call sm-var-temp, _cflags,           :=, $(strip $(sm.global.compile.flags) $(sm.module.compile.flags)))
$(call sm-var-temp, _cflags.c,         :=, $(strip $(sm.global.compile.flags.c) $(sm.module.compile.flags.c)))
$(call sm-var-temp, _cflags.c++,       :=, $(strip $(sm.global.compile.flags.c++) $(sm.module.compile.flags.c++)))
$(call sm-var-temp, _cflags.asm,       :=, $(strip $(sm.global.compile.flags.asm) $(sm.module.compile.flags.asm)))
$(call sm-var-temp, _cflags_infile,    :=, $(strip $(sm.module.compile.flags.infile)))

## combine alias
sm.var.temp._cflags     += $(strip $(sm.global.compile.options) $(sm.module.compile.options))
sm.var.temp._cflags.c   += $(strip $(sm.global.compile.options.c) $(sm.module.compile.options.c))
sm.var.temp._cflags.c++ += $(strip $(sm.global.compile.options.c++) $(sm.module.compile.options.c++))
sm.var.temp._cflags.asm += $(strip $(sm.global.compile.options.asm) $(sm.module.compile.options.asm))

ifeq ($(sm.var.temp._cflags_infile),)
  ifeq ($(strip $(sm.module.compile.options.infile)),true)
    sm.var.temp._cflags_infile := true
  endif
endif

_sm_has_sources.asm := $(if $(sm.var.temp._sources_fix.asm)$(sm.var.temp._sources_rel.asm),true,)
_sm_has_sources.t   := $(if $(sm.var.temp._sources_fix.t)$(sm.var.temp._sources_rel.t),true,)
_sm_has_sources.c   := $(if $(sm.var.temp._sources_fix.c)$(sm.var.temp._sources_rel.c),true,)
_sm_has_sources.c++ := $(if $(sm.var.temp._sources_fix.c++)$(sm.var.temp._sources_rel.c++),true,)
_sm_has_sources.h   := $(if $(sm.var.temp._sources_fix.h)$(sm.var.temp._sources_rel.h),true,)

## Compute include path (-I switches).
$(call sm-var-temp, _includes, :=)
$(foreach v,$(sm.global.includes),\
  $(if $(patsubst -I%,%,$v),$(eval sm.var.temp._includes += -I$$(patsubst -I%,%,$$v))))
$(foreach v,$(sm.module.includes),\
  $(if $(patsubst -I%,%,$v),$(eval sm.var.temp._includes += -I$$(patsubst -I%,%,$$v))))


## Compute compile flages for sources
$(call sm-var-temp, _compile_flags.c++, :=, $(sm.var.temp._includes))
sm.var.temp._compile_flags.c++ += \
  $(sm.var.temp._cflags) \
  $(sm.var.temp._cflags.c++)

$(call sm-var-temp, _compile_flags.c, :=, $(sm.var.temp._includes))
sm.var.temp._compile_flags.c += \
  $(sm.var.temp._cflags) \
  $(sm.var.temp._cflags.c)

$(call sm-var-temp, _compile_flags.asm, :=, $(sm.var.temp._includes))
sm.var.temp._compile_flags.asm += \
  $(sm.var.temp._compile_flags.asm)

#sm.var.temp._compile_flags.asm := $(filter-out -O3,$(sm.var.temp._compile_flags.asm))

ifeq ($(_sm_has_sources.t),true)
  ifeq ($(sm.module.lang),)
    $(error Must set 'sm.module.lang' for '.t' sources)
  endif
  ifeq ($(filter $(sm.module.lang),c c++),)
    $(error 'sm.module.lang' must be one of 'c c++')
  endif
  sm.var.temp._compile_flags.t += -x$(sm.module.lang) \
    $(sm.var.temp._compile_flags.$(sm.module.lang))
endif

## The compilation command
$(call sm-var-temp, _compile.c++, =)
$(call sm-var-temp, _compile.c, =)
$(call sm-var-temp, _compile.t, =)
$(call sm-var-temp, _compile.asm, =)
ifeq ($(sm.var.temp._cflags_infile),true)
  $(call sm-util-mkdir,$(sm.dir.out.tmp))
  $(if $(_sm_has_sources.c++),$(shell echo -c $(sm.var.temp._compile_flags.c++) > $(sm.dir.out.tmp)/$(sm.module.name).c++.opts))
  $(if $(_sm_has_sources.c),$(shell echo -c $(sm.var.temp._compile_flags.c) > $(sm.dir.out.tmp)/$(sm.module.name).c.opts))
  $(if $(_sm_has_sources.t),$(shell echo -c $(sm.var.temp._compile_flags.t) > $(sm.dir.out.tmp)/$(sm.module.name).t.opts))
  $(if $(_sm_has_sources.asm),$(shell echo $(sm.var.temp._compile_flags.asm) > $(sm.dir.out.tmp)/$(sm.module.name).asm.opts))
  sm.var.temp._compile.c++ = $(CXX) @$(sm.dir.out.tmp)/$(sm.module.name).c++.opts -o $$@ $$<
  sm.var.temp._compile.c = $(CC) @$(sm.dir.out.tmp)/$(sm.module.name).c.opts -o $$@ $$<
  sm.var.temp._compile.t = $(CC) @$(sm.dir.out.tmp)/$(sm.module.name).t.opts -o $$@ $$<
  sm.var.temp._compile.asm = $(AS) @$(sm.dir.out.tmp)/$(sm.module.name).asm.opts -o $$@ $$<
else
  sm.var.temp._compile.c++ = $(CXX) -c $(sm.var.temp._compile_flags.c++) -o $$@ $$<
  sm.var.temp._compile.c = $(CC) -c $(sm.var.temp._compile_flags.c) -o $$@ $$<
  sm.var.temp._compile.t = $(CC) -c $(sm.var.temp._compile_flags.t) -o $$@ $$<
  sm.var.temp._compile.asm = $(AS) $(sm.var.temp._compile_flags.asm) -o $$@ $$<
endif

$(call sm-var-temp, _gen.c++, =)
$(call sm-var-temp, _gen.c, =)
$(call sm-var-temp, _gen.t, =)
$(call sm-var-temp, _gen.asm, =)
sm.var.temp._gen.c++ = \
  ( echo "C++: $(sm.module.name) += $$(<:$(sm.dir.top)/%=%)" )\
  && ( $(call _sm_log,$(sm.var.temp._compile.c++)) )\
  && ( $(sm.var.temp._compile.c++) || $(call _sm_log,"failed: $$<") )

sm.var.temp._gen.c = \
  ( echo "C: $(sm.module.name) += $$(<:$(sm.dir.top)/%=%)" )\
  && ( $(call _sm_log,$(sm.var.temp._compile.c)) )\
  && ( $(sm.var.temp._compile.c) || $(call _sm_log,"failed: $$<") )

sm.var.temp._gen.t = \
  ( echo "test: $(sm.module.name) += $$(<:$(sm.dir.top)/%=%)" )\
  && ( $(call _sm_log,$(sm.var.temp._compile.t)) )\
  && ( $(sm.var.temp._compile.t) || $(call _sm_log,"failed: $$<") )

sm.var.temp._gen.asm = \
  ( echo "ASM: $(sm.module.name) += $$(<:$(sm.dir.top)/%=%)" )\
  && ( $(call _sm_log,$(sm.var.temp._compile.asm)) )\
  && ( $(sm.var.temp._compile.asm) || $(call _sm_log,"failed: $$<") )

ifeq ($(sm.module.gen_deps),true)
  sm.var.temp._dep.c++ = $(CXX) -MM -MT $1 -MF $$@ $(sm.var.temp._compile_flags.c++) $$<
  sm.var.temp._dep.c = $(CC) -MM -MT $1 -MF $$@ $(sm.var.temp._compile_flags.c) $$<
  sm.var.temp._dep.t = $(CC) -MM -MT $1 -MF $$@ $(sm.var.temp._compile_flags.t) $$<
endif # $(sm.module.gen_deps) == true

ifneq ($(sm.module.prebuilt_objects),)
  $(error sm.module.prebuilt_objects is deprecated, use sm.module.objects instead)
endif

$(call sm-var-temp, _out, :=,$(call sm-to-relative-path,$(sm.dir.out.obj)))
$(call sm-var-temp, _prefix, :=,$(sm.var.temp._out)$(sm.module.dir:$(sm.dir.top)%=%))
sm.fun.cal-obj = $(sm.var.temp._prefix)/$(subst ..,_,$(basename $(call sm-to-relative-path,$1)).o)

## Compute objects
$(foreach v,$(sm.var.temp._sources_fix) $(sm.var.temp._sources_rel),\
   $(eval o := $(call sm.fun.cal-obj,$v))\
   $(if $(filter $o,$(sm.module.objects)),,$(eval sm.module.objects += $o)))

#_sm_has_sources.t

## Prepare output directories
$(foreach v,$(sm.module.objects),$(call sm-util-mkdir,$(dir $v)))

sm.fun.cal-src-fix = $(strip $1)
sm.fun.cal-src-rel = $(sm.module.dir)/$(strip $1)

ifeq ($(sm.module.gen_deps),true)
define sm.fun.gen-depend
 ifneq ($(filter $1,c c++ t),)
 -include $(o:%.o=%.d)
 $(o:%.o=%.d): $(call sm.fun.cal-src-$2, $s)
	$(sm.var.Q)( echo smart: dependency $$@ )&&\
	( $(call sm.var.temp._dep.$1,$o) )
 endif
endef
endif # $(sm.module.gen_deps) == true

define sm.fun.gen-object-rule
sm.module.objects.defined += $o
$o : $(call sm.fun.cal-src-$2, $s)
	$(sm.var.Q)$(sm.var.temp._gen.$1)
ifeq ($(sm.module.gen_deps),true)
  $(call sm.fun.gen-depend,$1,$2)
endif # $(sm.module.gen_deps) == true
endef

define sm.fun.gen-object-rules
$(foreach s,$(sm.var.temp._sources_$2.$1),\
   $(eval o := $(call sm.fun.cal-obj,$s))\
   $(if $(filter $o,$(sm.module.objects.defined)),\
        $(info smart: duplicated $s),\
      $(eval $(call sm.fun.gen-object-rule,$1,$2))))
endef

$(call sm.fun.gen-object-rules,asm,fix)
$(call sm.fun.gen-object-rules,asm,rel)
$(call sm.fun.gen-object-rules,c,fix)
$(call sm.fun.gen-object-rules,c,rel)
$(call sm.fun.gen-object-rules,t,fix)
$(call sm.fun.gen-object-rules,t,rel)
$(call sm.fun.gen-object-rules,c++,fix)
$(call sm.fun.gen-object-rules,c++,rel)

$(sm-var-temp-clean)
