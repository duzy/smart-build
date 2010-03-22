# -*- mode: Makefile:gnu -*-
#	Copyright(c) 2009, by Zhan Xin-ming, duzy@duzy.info
#

## This file define rules for objects of C, C++, etc. sources


## Compute sources
$(call sm-var-local, _sources.cpp, :=, $(filter %.cpp %.C %.cc %.CC,$(sm.module.sources)))
$(call sm-var-local, _sources.c,   :=, $(filter %.c,$(sm.module.sources)))
$(call sm-var-local, _sources.asm, :=, $(filter %.s,$(sm.module.sources)))


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

$(call sm-var-local, _compile_cmd.cpp, =)
$(call sm-var-local, _compile_cmd.c, =)
sm.var.local._compile_cmd.cpp = \
  @echo "C++: $(sm.module.name) += $$(<:$(sm.dir.top)/%=%)" \
  && $(call _sm_log,$(sm.var.local._compile.cpp)) \
  && ( $(sm.var.local._compile.cpp) || $(call _sm_log,"failed: $$<") )
sm.var.local._compile_cmd.c = \
  @echo "C: $(sm.module.name) += $$(<:$(sm.dir.top)/%=%)" \
  && $(call _sm_log,$(sm.var.local._compile.c)) \
  && ( $(sm.var.local._compile.c) || $(call _sm_log,"failed: $$<") )


## Generate rules
d := $(sm.dir.out.obj)
$(foreach v,$(sm.module.sources),\
  $(call _sm_mk_out_dir,$(dir $d$r/$(subst ..,_,$v))))

static_rules := false
ifeq ($(static_rules),true)
  $(sm.var.local._sources.cpp): 
  $(sm.var.local._sources.c): 
else
  $(foreach v,$(sm.var.local._sources.cpp),$(eval s := $(suffix $v))\
    $(eval $d$r/$$(subst ..,_,$(v:%$s=%.o)) : $(sm.module.dir)/$v ; $(sm.var.local._compile_cmd.cpp)))
  $(foreach v,$(sm.var.local._sources.c),$(eval s := $(suffix $v))\
    $(eval $d$r/$$(subst ..,_,$(v:%$s=%.o)) : $(sm.module.dir)/$v ; $(sm.var.local._compile_cmd.c)))
endif

ifneq ($(sm.module.prebuilt_objects),)
  $(error sm.module.prebuilt_objects is deprecated, use sm.module.objects instead)
endif

#sm.module.objects := $(sm.module.prebuilt_objects)

## Compute objects
$(foreach v,$(sm.module.sources),$(eval s:=$(suffix $v))\
   $(eval sm.module.objects += $(sm.dir.out.obj)$r/$$(subst ..,_,$(v:%$s=%.o))))


#$(info smart: local vars: $(sm.var.local.*))
$(sm-var-local-clean)
