# -*- mode: Makefile:gnu -*-
#	Copyright(c) 2009, by Zhan Xin-ming, duzy@duzy.info
#

## Archive command
_sm_archive = $(AR) crus


#_sm_link = $(_sm_archive) $$@ $$^
_sm_log = $(if $(sm.log.filename),\
  echo $(AR) cm $$@ ... >> $(sm.dir.out)/$(sm.log.filename),true)
_sm_link = for o in $$^ ; do $(_sm_archive) $$@ $$$$o || exit ; done \
  && ranlib $$@


## Target Rule
_sm_rel_name = $(if $(1:$(sm.dir.top)/%=%),$(1:$(sm.dir.top)/%=%),$1)
_sm_link_cmd := \
  @echo "$(sm.module.type): $$(call _sm_rel_name,$$@)" \
  && $(call _sm_log,$(_sm_link)) && $(_sm_link)

$(if $(sm.module.sources),\
   $(call _sm_mk_out_dir, $(dir $(sm.dir.out.lib)/$(sm.module.name))))

$(eval $(sm.dir.out.lib)/$(sm.module.name): $(_sm_objs) ; $(_sm_link_cmd))
