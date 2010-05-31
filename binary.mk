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

$(call sm-var-temp, _out_bin, :=,$(call sm-to-relative-path,$(sm.dir.out.bin)))
$(call sm-var-temp, _out_lib, :=,$(call sm-to-relative-path,$(sm.dir.out.lib)))

ifeq ($(sm.module.type),shared)
  _sm_link_flags.cpp := -shared $(strip $(_sm_link_flags.cpp))

  ifeq ($(sm.os.name),win32)
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


## rpath and rpath-link
ifneq ($(sm.module.rpath),)
  _sm_link_flags.cpp += $(sm.module.rpath:%=-Wl,-rpath,%)
endif
ifneq ($(sm.module.rpath-link),)
  _sm_link_flags.cpp += $(sm.module.rpath-link:%=-Wl,-rpath-link,%)
endif

## C++ link command
ifeq ($(sm.module.options.link.infile),true)
  $(shell echo $(_sm_link_flags.cpp) > $(sm.dir.out.tmp)/$(sm.module.name).opts)
  _sm_link.cpp = $(CXX) @$(sm.dir.out.tmp)/$(sm.module.name).opts
  _sm_link.c = $(CC) @$(sm.dir.out.tmp)/$(sm.module.name).opts
else
  _sm_link.cpp = $(CXX) $(_sm_link_flags.cpp)
  _sm_link.c = $(CC) $(_sm_link_flags.cpp)
endif


## If sources contains mixed .cpp and .c suffix, we should use C++ linker.
s := $(strip $(if $(_sm_has_sources.cpp), .cpp, .c))
ifeq ($(sm.module.options.link.infile),true)
  #_sm_link = $(_sm_link$s) -o $$@ $$(wordlist 1,100,$$^)
  $(shell echo $(sm.module.objects) > $(sm.dir.out.tmp)/$(sm.module.name).objs)
  _sm_link = $(_sm_link$s) -o $$@ @$(sm.dir.out.tmp)/$(sm.module.name).objs
else
  _sm_link = $(_sm_link$s) -o $$@ $$^
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

$(if $(sm.module.sources),\
   $(call sm-util-mkdir,$(dir $(sm.var.temp._out_bin)/$(sm.module.name))))

$(if $(_sm_implib), $(call sm-util-mkdir,$(dir $(_sm_implib))))

define _sm_rules
$(sm.var.temp._out_bin)/$(sm.module.name)$(sm.module.suffix) $(_sm_implib): \
  $(sm.module.objects)
	$(sm.var.Q)( echo "$(sm.module.type): $$(call _sm_rel_name,$$@)" )\
	&&( $(call _sm_log,$(_sm_link)) )\
	&&( echo $(_sm_link) )\
	&&( $(_sm_link) )
endef
$(eval $(_sm_rules))

_sm_rules :=

$(sm-var-temp-clean)

