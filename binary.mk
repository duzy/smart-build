# -*- mode: Makefile:gnu -*-
#	Copyright(c) 2009, by Zhan Xin-ming, duzy@duzy.info
#

## Compute lib path and libs for (-L and -l switches).
_sm_libs := 
_sm_lib_dirs :=
_sm_append_lib_dir = $(if $(patsubst -L%,%,$1), \
  $(eval _sm_lib_dirs += -L$$(patsubst -L%,%,$$1)))
_sm_append_lib = $(if $(patsubst -l%,%,$1), \
  $(eval _sm_libs += -l$$(patsubst -l%,%,$$1)))
$(foreach v,$(sm.global.dirs.lib),$(call _sm_append_lib_dir,$v))
$(foreach v,$(sm.global.libs),$(call _sm_append_lib,$v))
$(foreach v,$(sm.module.dirs.lib),$(call _sm_append_lib_dir,$v))
$(foreach v,$(sm.module.libs),$(call _sm_append_lib,$v))
_sm_append_lib_dir :=
_sm_append_lib :=


## Compute the link flags.
_sm_link_flags.cpp := \
  $(strip $(filter-out -shared,$(sm.global.options.link))) \
  $(strip $(filter-out -shared,$(sm.module.options.link)))
ifeq ($(sm.module.type),static)
  $(error Internal error to build static target as 'binary', it should be 'archive'.)
endif ## sm.module.type == static

ifeq ($(sm.module.type),shared)
  _sm_link_flags.cpp := -shared $(strip $(_sm_link_flags.cpp))

  $(info TODO: --out-implib for $(sm.config.uname))
  ifeq ($(sm.config.uname),MinGW)
    ## --out-implib on Win32
    _sm_implib := $(strip $(sm.module.out_implib))
    ifneq ($s,)
      _sm_implib := $(sm.dir.out.lib)/lib$(patsubst lib%.a,%,$(_sm_implib)).a
      _sm_link_flags.cpp += -Wl,--out-implib,$(_sm_implib)
    endif
  endif

endif ## sm.module.type == shared
_sm_link_flags.cpp += $(strip $(_sm_lib_dirs))


## C++ link command
_sm_link.cpp = $(CXX) $(_sm_link_flags.cpp)
_sm_link.c = $(CC) $(_sm_link_flags.cpp)


## If sources contains mixed .cpp and .c suffix, we should use C++ linker.
s := $(strip $(if $(_sm_sources.cpp), .cpp, .c))
_sm_link = $(_sm_link$s) -o $$@ $$^
ifeq ($(sm.module.type),shared)
  ifneq ($(strip $(sm.module.whole_archives)),)
    _sm_link += -Wl,--whole-archive \
       $(sm.module.whole_archives:%=-l%) -Wl,--no-whole-archive
  endif
endif
_sm_link += $(strip $(_sm_libs))

## Target Rule
_sm_rel_name = $(if $(1:$(sm.dir.top)/%=%),$(1:$(sm.dir.top)/%=%),$1)
_sm_link_cmd := \
  @echo "$(sm.module.type): $$(call _sm_rel_name,$$@)" \
  && $(call _sm_log,$(_sm_link)) && $(_sm_link)

$(if $(sm.module.sources),\
   $(call _sm_mk_out_dir, $(dir $(sm.dir.out.bin)/$(sm.module.name))))

$(if $(_sm_implib), $(call _sm_mk_out_dir, $(dir $(_sm_implib))))

$(eval $(sm.dir.out.bin)/$(sm.module.name)$(sm.module.suffix) $(_sm_implib): $(sm.module.objects) ; $(_sm_link_cmd))

_sm_link_cmd :=

$(sm-var-local-clean)
