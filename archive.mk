# -*- mode: Makefile:gnu -*-
#	Copyright(c) 2009, by Zhan Xin-ming, duzy@duzy.info
#

$(call sm-var-temp, _out,          :=, $(call sm.fun.to-relative,$(sm.dir.out)))
$(call sm-var-temp, _out_lib,      :=, $(call sm.fun.to-relative,$(sm.dir.out.lib)))
$(call sm-var-temp, _archive_cmd,  :=, $(AR) cur)
$(call sm-var-temp, _archive_name, :=, $(sm.module.name)$(sm.module.suffix))
$(call sm-var-temp, _archive,      :=, $(sm.var.temp._out_lib)/$(sm.var.temp._archive_name))
$(call sm-var-temp, _numobjs,      :=, $(words $(sm.module.objects)))
$(call sm-var-temp, _prompt,       :=, echo "$(sm.module.type): $(sm.var.temp._archive) ($(sm.var.temp._numobjs) objects)")

ifeq ($(sm.var.temp._archive_name),)
  $(error archive name is empty)
endif

$(call sm-var-temp, _ar, =)
sm.var.temp._ar = $(sm.var.temp._archive_cmd) $(sm.var.temp._archive)

$(call sm-var-temp, _log, =)
sm.var.temp._log = $(if $(and $(sm.log.enabled),$(sm.log.filename)),\
  echo $(sm.var.temp._ar) ... >> $(sm.var.temp._out)/$(sm.log.filename),true)

$(if $(sm.module.sources),\
   $(call sm-util-mkdir,$(dir $(sm.var.temp._out_lib)/$(sm.module.name))))

$(call sm-var-temp, _gen, =,\
   ($(sm.var.temp._prompt))&&\
   ($(sm.var.temp._log))&&\
   (for o in $(sm.module.objects) ; do ($(sm.var.temp._ar) $$$$$$$$o && echo '  + '$$$$$$$$o) || exit ; done)&&\
   (ranlib $(sm.var.temp._archive)))

ifeq ($(sm.var.temp._archive),)
  $(error archive target unknown)
else
  $(eval $(sm.var.temp._archive): \
      $(sm.module.objects) ; @$(sm.var.temp._gen))
endif

$(sm-var-temp-clean)
