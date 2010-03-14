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
$(foreach v,$(SM_GLOBAL_LIB_DIRS),$(call _sm_append_lib_dir,$v))
$(foreach v,$(SM_GLOBAL_LIBS),$(call _sm_append_lib,$v))
$(foreach v,$(SM_MODULE_LIB_DIRS),$(call _sm_append_lib_dir,$v))
$(foreach v,$(SM_MODULE_LIBS),$(call _sm_append_lib,$v))
_sm_append_lib_dir :=
_sm_append_lib :=


## Compute the link flags.
_sm_link_flags.cpp := \
  $(strip $(filter-out -shared,$(SM_GLOBAL_LINK_FLAGS))) \
  $(strip $(filter-out -shared,$(SM_MODULE_LINK_FLAGS)))
ifneq ($(SM_MODULE_TYPE),static)
  ifeq ($(SM_MODULE_TYPE),dynamic)
    _sm_link_flags.cpp := -shared $(strip $(_sm_link_flags.cpp))

    ## --out-implib on Win32
    _sm_implib := $(strip $(SM_MODULE_OUT_IMPLIB))
    ifneq ($s,)
      _sm_implib := $(SM_OUT_DIR_lib)/lib$(patsubst lib%.a,%,$(_sm_implib)).a
      _sm_link_flags.cpp += -Wl,--out-implib,$(_sm_implib)
    endif

  endif
  _sm_link_flags.cpp += $(strip $(_sm_lib_dirs))
endif


## C++ link command
_sm_link.cpp = $(CXX) $(_sm_link_flags.cpp)
_sm_link.c = $(CC) $(_sm_link_flags.cpp)


## If sources contains mixed .cpp and .c suffix, we should use C++ linker.
s := $(strip $(if $(_sm_sources.cpp), .cpp, .c))
_sm_link = $(_sm_link$s) -o $$@ $$^
ifeq ($(SM_MODULE_TYPE),dynamic)
  ifneq ($(strip $(SM_MODULE_WHOLE_ARCHIVES)),)
    _sm_link += -Wl,--whole-archive \
       $(SM_MODULE_WHOLE_ARCHIVES:%=-l%) -Wl,--no-whole-archive
  endif
endif
_sm_link += $(strip $(_sm_libs))

## Target Rule
_sm_rel_name = $(if $(1:$(SM_TOP_DIR)/%=%),$(1:$(SM_TOP_DIR)/%=%),$1)
_sm_link_cmd := \
  @echo "$(SM_MODULE_TYPE): $$(call _sm_rel_name,$$@)" \
  && $(call _sm_log,$(_sm_link)) && $(_sm_link)

$(if $(SM_MODULE_SOURCES),\
   $(call _sm_mk_out_dir, $(dir $(SM_OUT_DIR_bin)/$(SM_MODULE_NAME))))

$(if $(_sm_implib), $(call _sm_mk_out_dir, $(dir $(_sm_implib))))

$(eval $(SM_OUT_DIR_bin)/$(SM_MODULE_NAME) $(_sm_implib): $(_sm_objs) ; $(_sm_link_cmd))

_sm_link_cmd :=

