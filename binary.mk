# -*- mode: Makefile:gnu -*-
#	Copyright(c) 2009, by Zhan Xin-ming, duzy@duzy.info
#

ifeq ($(sm.module.type),static)
  $(error Internal error to build static target as 'binary', it should be 'archive')
endif ## sm.module.type == static

## Compute lib path and libs for (-L and -l switches).
$(call sm-var-temp, _libs, :=)
$(call sm-var-temp, _lib_dirs, :=)
sm.fun._append_lib_dir = $(if $(patsubst -L%,%,$1), \
  $(eval sm.var.temp._lib_dirs += -L$$(patsubst -L%,%,$$1)))
sm.fun._append_lib = $(if $(patsubst -l%,%,$1), \
  $(eval sm.var.temp._libs += -l$$(patsubst -l%,%,$$1)))
$(foreach v,$(sm.global.libdirs),$(call sm.fun._append_lib_dir,$v))
$(foreach v,$(sm.global.libs),$(call sm.fun._append_lib,$v))
$(foreach v,$(sm.module.libdirs),$(call sm.fun._append_lib_dir,$v))
$(foreach v,$(sm.module.libs),$(call sm.fun._append_lib,$v))
sm.fun._append_lib_dir :=
sm.fun._append_lib :=


## Compute the link flags.
_sm_link_flags := \
  $(strip $(sm.global.link.flags) $(sm.module.link.options)) \
  $(strip $(sm.global.link.flags) $(sm.module.link.options))

_sm_link_flags := $(filter-out -shared,$(_sm_link_flags))

$(call sm-var-temp, _out_bin, :=,$(call sm-to-relative-path,$(sm.dir.out.bin)))
$(call sm-var-temp, _out_lib, :=,$(call sm-to-relative-path,$(sm.dir.out.lib)))

_sm_implib :=
_sm_ranlib := true
ifeq ($(sm.module.type),shared)
  _sm_link_flags := -shared $(strip $(_sm_link_flags))

  _sm_implib := $(strip $(sm.module.out_implib))
  ifneq ($(_sm_implib),)
  ifeq ($(sm.os.name),win32)
    ## --out-implib on Win32
    _sm_implib := $(sm.var.temp._out_lib)/lib$(patsubst lib%.a,%,$(_sm_implib)).a
    _sm_link_flags += -Wl,--out-implib,$(_sm_implib)
  else
  ifeq ($(sm.os.name),linux)
    ## --out-implib for Linux: just make linkage to the shared library.
    _sm_implib := $(sm.var.temp._out_lib)/lib$(patsubst lib%.so,%,$(_sm_implib)).so
    _sm_ranlib := ( mkdir -p $(sm.var.temp._out_lib) )\
      &&( cd $(sm.var.temp._out_lib) )\
      &&( ln -svf ../bin/$(sm.module.name)$(sm.module.suffix) ./$(_sm_implib) )
  endif#if linux
  endif#if win32
  endif#if has sm.module.out_impllib

endif ## sm.module.type == shared
_sm_link_flags += $(strip $(sm.var.temp._lib_dirs))


## rpath and rpath-link
ifneq ($(sm.module.rpath),)
  _sm_link_flags += $(sm.module.rpath:%=-Wl,-rpath,%)
endif
ifneq ($(sm.module.rpath-link),)
  _sm_link_flags += $(sm.module.rpath-link:%=-Wl,-rpath-link,%)
endif

$(call sm-var-temp, _flags_infile, :=, $(strip $(sm.module.link.flags.infile)))
ifeq ($(sm.var.temp._flags_infile),)
  sm.var.temp._flags_infile := true
endif

## C++ link command
ifeq ($(sm.var.temp._flags_infile),true)
  $(call sm-util-mkdir,$(sm.dir.out.tmp))
  $(shell echo $(_sm_link_flags) > $(sm.dir.out.tmp)/$(sm.module.name).opts)
  _sm_link.c++ = $(CXX) @$(sm.dir.out.tmp)/$(sm.module.name).opts
  _sm_link.c = $(CC) @$(sm.dir.out.tmp)/$(sm.module.name).opts
else
  _sm_link.c++ = $(CXX) $(_sm_link_flags)
  _sm_link.c = $(CC) $(_sm_link_flags)
endif

## If sources contains mixed .c++ and .c suffix, we should use C++ linker.
_sm_suffix := $(if $(_sm_has_sources.c++),.c++,\
      $(if $(_sm_has_sources.c),.c,\
       $(if $(filter $(sm.module.lang),c c++),$(sm.module.lang),\
         $(error Unsupported langauge '$(sm.module.lang)'))))
_sm_suffix := $(strip $(_sm_suffix))
$(if $(_sm_link$(_sm_suffix)),,$(error Undefined link command for $(_sm_suffix)))
ifeq ($(sm.var.temp._flags_infile),true)
  #_sm_link = $(_sm_link$(_sm_suffix)) -o $$@ $$(wordlist 1,100,$$^)
  $(call sm-util-mkdir,$(sm.dir.out.tmp))
  $(shell echo $(sm.module.objects) > $(sm.dir.out.tmp)/$(sm.module.name).objs)
  _sm_link = $(_sm_link$(_sm_suffix)) -o $$@ @$(sm.dir.out.tmp)/$(sm.module.name).objs
else
  _sm_link = $(_sm_link$(_sm_suffix)) -o $$@ $$^
endif
ifeq ($(sm.module.type),shared)
  ifneq ($(strip $(sm.module.whole_archives)),)
    _sm_link += -Wl,--whole-archive \
       $(sm.module.whole_archives:%=-l%) -Wl,--no-whole-archive
  endif
endif
_sm_link += $(strip $(sm.var.temp._libs))

## Target Rule
_sm_rel_name = $(if $(1:$(sm.dir.top)/%=%),$(1:$(sm.dir.top)/%=%),$1)

define sm.fun.gen-binary-rule
$(sm.var.temp._out_bin)/$(sm.module.name)$(sm.module.suffix) $(_sm_implib): \
  $(sm.module.objects)
	$$(call sm-util-mkdir,$$(dir $$@))
	$(if $(_sm_implib),$$(call sm-util-mkdir,$(dir $(_sm_implib))))
	$(sm.var.Q)( echo "$(sm.module.type): $$(call _sm_rel_name,$$@)" )\
	&&( $(call _sm_log,$(_sm_link)) )\
	&&( $(_sm_link) )&&( $(_sm_ranlib) )
endef
$(eval $(sm.fun.gen-binary-rule))

sm.fun.gen-binary-rule :=

$(sm-var-temp-clean)

