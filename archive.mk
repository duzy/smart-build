# -*- mode: Makefile:gnu -*-
#	Copyright(c) 2009, by Zhan Xin-ming, duzy@duzy.info
#

$(call sm-var-local, _archive_cmd, :=, $(AR) cr)
$(call sm-var-local, _archive_name, :=, $(sm.module.name)$(sm.module.suffix))
$(call sm-var-local, _archive, :=, $(sm.dir.out.lib)/$(sm.var.local._archive_name))
$(call sm-var-local, _prompt, :=, echo "$(sm.module.type): $(sm.var.local._archive)")

$(call sm-var-local, _link, =)
sm.var.local._link = for o in $(sm.module.objects) ; do \
  $(sm.var.local._archive_cmd) $(sm.var.local._archive) $$$$$$$$o || exit ; done \
  && ranlib $(sm.var.local._archive)

$(call sm-var-temp, _log, =)
sm.var.temp._log = $(if $(and $(sm.log.enabled),$(sm.log.filename)),\
  echo $(sm.var.temp._link) ... >> $(sm.dir.out)/$(sm.log.filename),true)

$(if $(sm.module.sources),\
   $(call sm-util-mkdir, $(dir $(sm.dir.out.lib)/$(sm.module.name))))

$(call sm-var-temp, _gen, =,\
   ($(sm.var.temp._prompt))&&\
   ($(sm.var.temp._log))&&\
   ($(sm.var.temp._link)))

$(eval $(sm.var.temp._archive): \
    $(sm.module.objects) ; @$(sm.var.temp._gen))

$(sm-var-temp-clean)
