# -*- mode: Makefile:gnu -*-
#	Copyright(c) 2009, by Zhan Xin-ming, duzy@duzy.info
#

$(call sm-var-local, _archive_cmd, :=, $(AR) crus)
$(call sm-var-local, _archive_name, :=, $(sm.module.name)$(sm.module.suffix))
$(call sm-var-local, _archive, :=, $(sm.dir.out.lib)/$(sm.var.local._archive_name))
$(call sm-var-local, _prompt, :=, echo "$(sm.module.type): $(sm.var.local._archive)")

$(call sm-var-local, _link, =)
sm.var.local._link = for o in $(sm.module.objects) ; do \
  $(sm.var.local._archive_cmd) $(sm.var.local._archive) $$$$o || exit ; done \
  && ranlib $(sm.var.local._archive)

$(call sm-var-local, _log, =)
sm.var.local._log = $(if $(and $(sm.log.enabled),$(sm.log.filename)),\
  echo $(sm.var.local._link) ... >> $(sm.dir.out)/$(sm.log.filename),true)

$(if $(sm.module.sources),\
   $(call _sm_mk_out_dir, $(dir $(sm.dir.out.lib)/$(sm.module.name))))

$(eval sm.rules.prompt.* += $(sm.var.local._archive_name))
$(eval sm.rules.prompt.$(sm.var.local._archive_name):; @$(sm.var.local._prompt))
$(eval sm.rules.log.* += $(sm.var.local._archive_name))
$(eval sm.rules.log.$(sm.var.local._archive_name):; @$(sm.var.local._log))
$(eval sm.rules.phony += \
    sm.rules.log.$(sm.var.local._archive_name) \
    sm.rules.prompt.$(sm.var.local._archive_name))
$(eval sm.rules.* += $(sm.var.local._archive))
$(eval $(sm.var.local._archive): \
    sm.rules.prompt.$(sm.var.local._archive_name) \
    sm.rules.log.$(sm.var.local._archive_name) \
    $(sm.module.objects) ; @$(sm.var.local._link))

#$(info sm.rules.prompt.* = $(sm.rules.prompt.*))
#$(info sm.rules.log.* = $(sm.rules.log.*))
#$(info sm.rules.phony = $(sm.rules.phony))
#$(info sm.rules.* = $(sm.rules.*))
#$(info $(sm.var.local.*))

$(sm-var-local-clean)
