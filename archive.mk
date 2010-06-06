# -*- mode: Makefile:gnu -*-
#	Copyright(c) 2009, by Zhan Xin-ming, duzy@duzy.info
#

$(call sm-var-temp, _out,          :=, $(call sm-to-relative-path,$(sm.dir.out)))
$(call sm-var-temp, _out_lib,      :=, $(call sm-to-relative-path,$(sm.dir.out.lib)))
$(call sm-var-temp, _archive_cmd,  :=, $(AR) cur)
$(call sm-var-temp, _archive_name, :=, $(sm.module.name)$(sm.module.suffix))

ifeq ($(sm.module.suffix),.a)
  ifneq ($(sm.var.temp._archive_name:lib%=ok),ok)
    sm.var.temp._archive_name := lib$(sm.var.temp._archive_name)
  endif
endif

$(call sm-var-temp, _archive,      :=, $(sm.var.temp._out_lib)/$(sm.var.temp._archive_name))
$(call sm-var-temp, _numobjs,      :=, $(words $(sm.module.objects)))
$(call sm-var-temp, _prompt,       :=, echo "$(sm.module.type): $(sm.var.temp._archive) ($(sm.var.temp._numobjs) objects)")

ifeq ($(sm.var.temp._archive_name),)
  $(error archive name is empty)
endif

ifeq ($(sm.var.temp._archive),)
  $(error archive target unknown)
endif

$(call sm-var-temp, _ar, =)
sm.var.temp._ar = $(sm.var.temp._archive_cmd) $(sm.var.temp._archive)

$(call sm-var-temp, _log, =)
sm.var.temp._log = $(if $(and $(sm.log.enabled),$(sm.log.filename)),\
  echo $(sm.var.temp._ar) ... >> $(sm.var.temp._out)/$(sm.log.filename),true)

$(if $(sm.module.sources),\
   $(call sm-util-mkdir,$(dir $(sm.var.temp._out_lib)/$(sm.module.name))))

#$(info objects: $(words $(sm.module.objects)) for $(sm.module.name))
#$(info objects: $(wordlist 1,50,$(sm.module.objects)) for $(sm.module.name))

$(call sm-var-temp, _objs, :=)
ifeq ($(sm.module.options.link.infile),true)
  $(call sm-util-mkdir,$(sm.dir.out.tmp))
  $(shell echo $(sm.module.objects) > $(sm.dir.out.tmp)/$(sm.module.name).objs)
   sm.var.temp._objs := @$(sm.dir.out.tmp)/$(sm.module.name).objs
else
   sm.var.temp._objs := $(sm.module.objects)
endif

define _sm_rules
 $(sm.var.temp._archive): $(sm.module.objects)
	$(sm.var.Q)( $(sm.var.temp._prompt) )&&\
	( $(sm.var.temp._log) )&&\
	( $(sm.var.temp._ar) $(sm.var.temp._objs) || exit -1 )&&\
	( ranlib $(sm.var.temp._archive) )
endef
$(eval $(_sm_rules))

$(sm-var-temp-clean)
