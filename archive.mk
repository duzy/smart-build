# -*- mode: Makefile:gnu -*-
#	Copyright(c) 2009, by Zhan Xin-ming, duzy@duzy.info
#

## Archive command
_sm_archive = $(AR) crus


#_sm_link = $(_sm_archive) $$@ $$^
_sm_log = $(if $(SM_COMPILE_LOG),\
  echo $(AR) cm $$@ ... >> $(SM_OUT_DIR)/$(SM_COMPILE_LOG),true)
_sm_link = for o in $$^ ; do $(_sm_archive) $$@ $$$$o || exit ; done \
  && ranlib $$@


## Target Rule
_sm_rel_name = $(if $(1:$(SM_TOP_DIR)/%=%),$(1:$(SM_TOP_DIR)/%=%),$1)
_sm_link_cmd := \
  @echo "$(SM_MODULE_TYPE): $$(call _sm_rel_name,$$@)" \
  && $(call _sm_log,$(_sm_link)) && $(_sm_link)

$(if $(SM_MODULE_SOURCES),\
   $(call _sm_mk_out_dir, $(dir $(SM_OUT_DIR_lib)/$(SM_MODULE_NAME))))

$(eval $(SM_OUT_DIR_lib)/$(SM_MODULE_NAME): $(_sm_objs) ; $(_sm_link_cmd))
