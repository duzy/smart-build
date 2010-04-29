# -*- mode: Makefile:gnu -*-
#	Copyright(c) 2009, by Zhan Xin-ming, duzy@duzy.info
#

## Compute lib path and libs for (-L and -l switches).
$(call sm-var-temp, _libs, :=)
$(call sm-var-temp, _lib_dirs, :=)
sm.fun._append_lib_dir = $(if $(patsubst -L%,%,$1), \
  $(eval sm.var.temp._lib_dirs += -L$$(patsubst -L%,%,$$1)))
sm.fun._append_lib = $(if $(patsubst -l%,%,$1), \
  $(eval sm.var.temp._libs += -l$$(patsubst -l%,%,$$1)))
$(foreach v,$(sm.global.dirs.lib),$(call sm.fun._append_lib_dir,$v))
$(foreach v,$(sm.global.libs),$(call sm.fun._append_lib,$v))
$(foreach v,$(sm.module.dirs.lib),$(call sm.fun._append_lib_dir,$v))
$(foreach v,$(sm.module.libs),$(call sm.fun._append_lib,$v))
sm.fun._append_lib_dir :=
sm.fun._append_lib :=


## Compute the link flags.
_sm_link_flags.cpp := \
  $(strip $(filter-out -shared,$(sm.global.options.link))) \
  $(strip $(filter-out -shared,$(sm.module.options.link)))
ifeq ($(sm.module.type),static)
  $(error Internal error to build static target as 'binary', it should be 'archive'.)
endif ## sm.module.type == static


ifeq ($(sm.fun.to-relative),)
  $(error sm.fun.to-relative undefined)
endif

$(call sm-var-temp, _out_bin, :=,$(call sm.fun.to-relative,$(sm.dir.out.bin)))
$(call sm-var-temp, _out_lib, :=,$(call sm.fun.to-relative,$(sm.dir.out.lib)))

ifeq ($(sm.module.type),shared)
  _sm_link_flags.cpp := -shared $(strip $(_sm_link_flags.cpp))

  ifeq ($(sm.config.uname),MinGW)
    ## --out-implib on Win32
    _sm_implib := $(strip $(sm.module.out_implib))
    ifneq ($s,)
      _sm_implib := $(sm.var.temp._out_lib)/lib$(patsubst lib%.a,%,$(_sm_implib)).a
      _sm_link_flags.cpp += -Wl,--out-implib,$(_sm_implib)
    endif
  else
    ifneq ($(sm.module.out_implib),)
      $(info smart: TODO: --out-implib=$(sm.module.out_implib) for $(sm.config.uname))
    endif
  endif

endif ## sm.module.type == shared
_sm_link_flags.cpp += $(strip $(sm.var.temp._lib_dirs))


## C++ link command
_sm_link.cpp = $(CXX) $(_sm_link_flags.cpp)
_sm_link.c = $(CC) $(_sm_link_flags.cpp)


## If sources contains mixed .cpp and .c suffix, we should use C++ linker.
s := $(strip $(if $(_sm_has_sources.cpp), .cpp, .c))
_sm_link = $(_sm_link$s) -o $$@ $$^
ifeq ($(sm.module.type),shared)
  ifneq ($(strip $(sm.module.whole_archives)),)
    _sm_link += -Wl,--whole-archive \
       $(sm.module.whole_archives:%=-l%) -Wl,--no-whole-archive
  endif
endif
_sm_link += $(strip $(sm.var.temp._libs))

## Target Rule
_sm_rel_name = $(if $(1:$(sm.dir.top)/%=%),$(1:$(sm.dir.top)/%=%),$1)
_sm_link_cmd := \
  @echo "$(sm.module.type): $$(call _sm_rel_name,$$@)" \
  && $(call _sm_log,$(_sm_link)) && $(_sm_link)

$(if $(sm.module.sources),\
   $(call sm-util-mkdir,$(dir $(sm.var.temp._out_bin)/$(sm.module.name))))

$(if $(_sm_implib), $(call sm-util-mkdir,$(dir $(_sm_implib))))

$(eval $(sm.var.temp._out_bin)/$(sm.module.name)$(sm.module.suffix) $(_sm_implib): $(sm.module.objects) ; $(_sm_link_cmd))

_sm_link_cmd :=

$(sm-var-temp-clean)
