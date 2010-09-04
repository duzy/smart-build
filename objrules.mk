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
$(call sm-var-temp, _sources_ext.asm,  :=, $(filter $(sm.var.temp._suffix.asm),$(sm.this.sources.external)))
$(call sm-var-temp, _sources_ext.c,    :=, $(filter $(sm.var.temp._suffix.c),  $(sm.this.sources.external)))
$(call sm-var-temp, _sources_ext.c++,  :=, $(filter $(sm.var.temp._suffix.c++),$(sm.this.sources.external)))
$(call sm-var-temp, _sources_ext.h,    :=, $(filter $(sm.var.temp._suffix.h),  $(sm.this.sources.external)))
$(call sm-var-temp, _sources_ext.t,    :=, $(filter $(sm.var.temp._suffix.t),  $(sm.this.sources.external)))
$(call sm-var-temp, _sources_ext,      :=, $(sm.var.temp._sources_ext.c) $(sm.var.temp._sources_ext.c++) $(sm.var.temp._sources_ext.asm) $(sm.var.temp._sources_ext.t))
$(call sm-var-temp, _sources_rel.asm,  :=, $(filter $(sm.var.temp._suffix.asm),$(sm.this.sources)))
$(call sm-var-temp, _sources_rel.c,    :=, $(filter $(sm.var.temp._suffix.c),  $(sm.this.sources)))
$(call sm-var-temp, _sources_rel.c++,  :=, $(filter $(sm.var.temp._suffix.c++),$(sm.this.sources)))
$(call sm-var-temp, _sources_rel.h,    :=, $(filter $(sm.var.temp._suffix.h),  $(sm.this.sources)))
$(call sm-var-temp, _sources_rel.t,    :=, $(filter $(sm.var.temp._suffix.t),  $(sm.this.sources)))
$(call sm-var-temp, _sources_rel,      :=, $(sm.var.temp._sources_rel.c) $(sm.var.temp._sources_rel.c++) $(sm.var.temp._sources_rel.asm) $(sm.var.temp._sources_rel.t))
$(call sm-var-temp, _cflags,           :=, $(strip $(sm.global.compile.flags) $(sm.this.compile.flags)))
$(call sm-var-temp, _cflags.c,         :=, $(strip $(sm.global.compile.flags.c) $(sm.this.compile.flags.c)))
$(call sm-var-temp, _cflags.c++,       :=, $(strip $(sm.global.compile.flags.c++) $(sm.this.compile.flags.c++)))
$(call sm-var-temp, _cflags.asm,       :=, $(strip $(sm.global.compile.flags.asm) $(sm.this.compile.flags.asm)))
$(call sm-var-temp, _cflags_infile,    :=, $(strip $(sm.this.compile.flags.infile)))

## combine alias
sm.var.temp._cflags     += $(strip $(sm.global.compile.options) $(sm.this.compile.options))
sm.var.temp._cflags.c   += $(strip $(sm.global.compile.options.c) $(sm.this.compile.options.c))
sm.var.temp._cflags.c++ += $(strip $(sm.global.compile.options.c++) $(sm.this.compile.options.c++))
sm.var.temp._cflags.asm += $(strip $(sm.global.compile.options.asm) $(sm.this.compile.options.asm))

ifeq ($(sm.var.temp._cflags_infile),)
  ifeq ($(strip $(sm.this.compile.options.infile)),true)
    sm.var.temp._cflags_infile := true
  endif
endif

_sm_has_sources.asm := $(if $(sm.var.temp._sources_ext.asm)$(sm.var.temp._sources_rel.asm),true,)
_sm_has_sources.t   := $(if $(sm.var.temp._sources_ext.t)$(sm.var.temp._sources_rel.t),true,)
_sm_has_sources.c   := $(if $(sm.var.temp._sources_ext.c)$(sm.var.temp._sources_rel.c),true,)
_sm_has_sources.c++ := $(if $(sm.var.temp._sources_ext.c++)$(sm.var.temp._sources_rel.c++),true,)
_sm_has_sources.h   := $(if $(sm.var.temp._sources_ext.h)$(sm.var.temp._sources_rel.h),true,)

## Compute include path (-I switches).
$(call sm-var-temp, _includes, :=)
$(foreach v,$(sm.global.includes),\
  $(if $(patsubst -I%,%,$v),$(eval sm.var.temp._includes += -I$$(patsubst -I%,%,$$v))))
$(foreach v,$(sm.this.includes),\
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
  ifeq ($(sm.this.lang),)
    $(error Must set 'sm.this.lang' for '.t' sources)
  endif
  ifeq ($(filter $(sm.this.lang),c c++),)
    $(error 'sm.this.lang' must be one of 'c c++')
  endif
  sm.var.temp._compile_flags.t += -x$(sm.this.lang) \
    $(sm.var.temp._compile_flags.$(sm.this.lang))
endif

## The compilation command
$(call sm-var-temp, _compile.c++, =)
$(call sm-var-temp, _compile.c, =)
$(call sm-var-temp, _compile.t, =)
$(call sm-var-temp, _compile.asm, =)
ifeq ($(sm.var.temp._cflags_infile),true)
  $(call sm-util-mkdir,$(sm.dir.out.tmp))
  $(if $(_sm_has_sources.c++),$(shell echo -c $(sm.var.temp._compile_flags.c++) > $(sm.dir.out.tmp)/$(sm.this.name).c++.opts))
  $(if $(_sm_has_sources.c),$(shell echo -c $(sm.var.temp._compile_flags.c) > $(sm.dir.out.tmp)/$(sm.this.name).c.opts))
  $(if $(_sm_has_sources.t),$(shell echo -c $(sm.var.temp._compile_flags.t) > $(sm.dir.out.tmp)/$(sm.this.name).t.opts))
  $(if $(_sm_has_sources.asm),$(shell echo $(sm.var.temp._compile_flags.asm) > $(sm.dir.out.tmp)/$(sm.this.name).asm.opts))
  sm.var.temp._compile.c++ = $(CXX) @$(sm.dir.out.tmp)/$(sm.this.name).c++.opts -o $$@ $$<
  sm.var.temp._compile.c = $(CC) @$(sm.dir.out.tmp)/$(sm.this.name).c.opts -o $$@ $$<
  sm.var.temp._compile.t = $(CC) @$(sm.dir.out.tmp)/$(sm.this.name).t.opts -o $$@ $$<
  sm.var.temp._compile.asm = $(AS) @$(sm.dir.out.tmp)/$(sm.this.name).asm.opts -o $$@ $$<
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
  ( echo "C++: $(sm.this.name) += $$(<:$(sm.dir.top)/%=%)" )\
  && ( $(call _sm_log,$(sm.var.temp._compile.c++)) )\
  && ( $(sm.var.temp._compile.c++) || $(call _sm_log,"failed: $$<") )

sm.var.temp._gen.c = \
  ( echo "C: $(sm.this.name) += $$(<:$(sm.dir.top)/%=%)" )\
  && ( $(call _sm_log,$(sm.var.temp._compile.c)) )\
  && ( $(sm.var.temp._compile.c) || $(call _sm_log,"failed: $$<") )

sm.var.temp._gen.t = \
  ( echo "test: $(sm.this.name) += $$(<:$(sm.dir.top)/%=%)" )\
  && ( $(call _sm_log,$(sm.var.temp._compile.t)) )\
  && ( $(sm.var.temp._compile.t) || $(call _sm_log,"failed: $$<") )

sm.var.temp._gen.asm = \
  ( echo "ASM: $(sm.this.name) += $$(<:$(sm.dir.top)/%=%)" )\
  && ( $(call _sm_log,$(sm.var.temp._compile.asm)) )\
  && ( $(sm.var.temp._compile.asm) || $(call _sm_log,"failed: $$<") )

ifeq ($(sm.this.gen_deps),true)
  sm.var.temp._dep.c++ = $(CXX) -MM -MT $1 -MF $$@ $(sm.var.temp._compile_flags.c++) $$<
  sm.var.temp._dep.c = $(CC) -MM -MT $1 -MF $$@ $(sm.var.temp._compile_flags.c) $$<
  sm.var.temp._dep.t = $(CC) -MM -MT $1 -MF $$@ $(sm.var.temp._compile_flags.t) $$<
endif # $(sm.this.gen_deps) == true

ifneq ($(sm.this.prebuilt_objects),)
  $(error sm.this.prebuilt_objects is deprecated, use sm.this.objects instead)
endif

$(call sm-var-temp, _out, :=,$(call sm-to-relative-path,$(sm.dir.out.obj)))
$(call sm-var-temp, _prefix, :=,$(sm.var.temp._out)$(sm.this.dir:$(sm.dir.top)%=%))
sm.fun.cal-obj = $(sm.var.temp._prefix)/$(subst ..,_,$(basename $(call sm-to-relative-path,$1)).o)

## Compute objects
$(foreach v,$(sm.var.temp._sources_ext) $(sm.var.temp._sources_rel),\
   $(eval o := $(call sm.fun.cal-obj,$v))\
   $(if $(filter $o,$(sm.this.objects)),,$(eval sm.this.objects += $o)))

sm.fun.cal-src-ext = $(strip $1)
sm.fun.cal-src-rel = $(sm.this.dir)/$(strip $1)

define sm.fun.gen-object-rule
  ifeq ($(sm.this.gen_deps),true)
    ifneq ($(filter $1,c c++ t),)
      -include $(sm._var._obj:%.o=%.d)
      $(sm._var._obj:%.o=%.d) : $(call sm.fun.cal-src-$2, $(sm._var._src))
	$(call sm-util-mkdir,$(dir $(sm._var._obj:%.o=%.d)))
	$(sm.var.Q)( echo smart: dependency $$@ )&&\
	( $(call sm.var.temp._dep.$1,$(sm._var._obj)) )
    endif
  endif # $(sm.this.gen_deps) == true

  sm.this.objects.defined += $(sm._var._obj)

  $(sm._var._obj) : $(call sm.fun.cal-src-$2, $(sm._var._src))
	$(call sm-util-mkdir,$(dir $(sm._var._obj)))
	$(sm.var.Q)$(sm.var.temp._gen.$1)
endef # sm.fun.gen-object-rule

define sm.fun.gen-object-rules
 $(foreach sm._var._src,$(sm.var.temp._sources_$2.$1),\
    $(eval sm._var._obj := $(call sm.fun.cal-obj,$(sm._var._src)))\
    $(if $(filter $(sm._var._obj),$(sm.this.objects.defined)),\
         $(info smart: duplicated $(sm._var._src)),\
       $(eval $(call sm.fun.gen-object-rule,$1,$2))))
endef # sm.fun.gen-object-rules

$(call sm.fun.gen-object-rules,asm,ext)
$(call sm.fun.gen-object-rules,asm,rel)
$(call sm.fun.gen-object-rules,c,ext)
$(call sm.fun.gen-object-rules,c,rel)
$(call sm.fun.gen-object-rules,t,ext)
$(call sm.fun.gen-object-rules,t,rel)
$(call sm.fun.gen-object-rules,c++,ext)
$(call sm.fun.gen-object-rules,c++,rel)

#$(info $(call sm.tool.$(sm.toolset.for.c).compile.c,foo/bar/test.o,foo/bar/test.c))

sm.fun.gen-object-rule :=
sm.fun.gen-object-rules :=

$(sm-var-temp-clean)
