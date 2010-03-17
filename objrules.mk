# -*- mode: Makefile:gnu -*-
#	Copyright(c) 2009, by Zhan Xin-ming, duzy@duzy.info
#

## This file define rules for objects of C, C++, etc. sources


## Compute sources
_sm_sources.cpp = $(filter %.cpp %.C %.cc %.CC,$(sm.module.sources))
_sm_sources.c = $(filter %.c,$(sm.module.sources))
_sm_sources.asm = $(filter %.s,$(sm.module.sources))


## Compute include path (-I switches).
_sm_includes :=
$(foreach v,$(sm.global.includes),\
  $(if $(patsubst -I%,%,$v),$(eval _sm_includes += -I$$(patsubst -I%,%,$$v))))
$(foreach v,$(sm.module.includes),\
  $(if $(patsubst -I%,%,$v),$(eval _sm_includes += -I$$(patsubst -I%,%,$$v))))


## Compute compile flages for sources
_sm_compile_flags.cpp = \
  $(strip $(_sm_includes)) \
  $(strip $(sm.global.options.compile)) \
  $(strip $(sm.module.options.compile))

_sm_compile_flags.c = \
  $(strip $(_sm_includes)) \
  $(strip $(sm.global.options.compile)) \
  $(strip $(sm.module.options.compile))


## The compilation command
_sm_compile.cpp = $(CXX) -c $(_sm_compile_flags.cpp) -o $$@ $$<
_sm_compile.c = $(CC) -c $(_sm_compile_flags.c) -o $$@ $$<

mixed_sources := false
ifeq ($(mixed_sources),true)
 _sm_compile = $(if $(v:%.c=),$(_sm_compile.cpp),$(_sm_compile.c))
 _sm_compile_cmd = \
  @echo "$(if $(v:%.c=),C++,C): $(sm.module.name) += $$(<:$(sm.dir.top)/%=%)" \
  && $(call _sm_log,$(_sm_compile)) \
  && ( $(_sm_compile) || $(call _sm_log,"failed: $$<") )
else
 _sm_compile_cmd.cpp = \
  @echo "C++: $(sm.module.name) += $$(<:$(sm.dir.top)/%=%)" \
  && $(call _sm_log,$(_sm_compile.cpp)) \
  && ( $(_sm_compile.cpp) || $(call _sm_log,"failed: $$<") )
 _sm_compile_cmd.c = \
  @echo "C: $(sm.module.name) += $$(<:$(sm.dir.top)/%=%)" \
  && $(call _sm_log,$(_sm_compile.c)) \
  && ( $(_sm_compile.c) || $(call _sm_log,"failed: $$<") )
endif


## Generate rules
d := $(sm.dir.out.obj)
$(foreach v,$(sm.module.sources),$(call _sm_mk_out_dir,$(dir $d$r/$v)))

static_rules := false
ifeq ($(static_rules),true)
  $(_sm_sources.cpp): 
  $(_sm_sources.c): 
else
  $(foreach v,$(_sm_sources.cpp),$(eval s := $(suffix $v))\
    $(eval $(v:%$s=$d$r/%.o) : $(sm.module.dir)/$v ; $(_sm_compile_cmd.cpp)))
  $(foreach v,$(_sm_sources.c),$(eval s := $(suffix $v))\
    $(eval $(v:%$s=$d$r/%.o) : $(sm.module.dir)/$v ; $(_sm_compile_cmd.c)))
endif

## Compute objects
_sm_objs := $(sm.module.prebuilt_objects)
ifneq ($(check_pure_source_type),true)
  $(foreach v,$(sm.module.sources),$(eval s:=$(suffix $v))\
     $(eval _sm_objs += $(v:%$s=$(sm.dir.out.obj)$r/%.o)))
else
  d :=
  _sm_pure_src := yes
  $(foreach v,$(sm.module.sources),$(eval s:=$(suffix $v))\
     $(if $(and $d, $(_sm_pure_src:no%=)),\
         $(eval _sm_pure_src := $(if $(v:%$d=),no,yes)) )\
     $(eval d:=$s)\
     $(eval _sm_objs += $(v:%$s=$(sm.dir.out.obj)$r/%.o)))
  d :=
endif

_sm_compile_cmd.cpp :=
_sm_compile_cmd.c :=

