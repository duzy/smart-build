# -*- mode: Makefile:gnu -*-
#	Copyright(c) 2009, by Zhan Xin-ming, duzy@duzy.info
#

$(call sm-var-temp, _out,          :=, $(call sm-to-relative-path,$(sm.out)))
$(call sm-var-temp, _out_lib,      :=, $(call sm-to-relative-path,$(sm.out.lib)))
$(call sm-var-temp, _archive_cmd,  :=, $(AR) cur)
$(call sm-var-temp, _archive_name, :=, $(sm.this.name)$(sm.this.suffix))

ifeq ($(sm.this.suffix),.a)
  ifneq ($(sm.var.temp._archive_name:lib%=ok),ok)
    sm.var.temp._archive_name := lib$(sm.var.temp._archive_name)
  endif
endif

$(call sm-var-temp, _archive,      :=, $(sm.var.temp._out_lib)/$(sm.var.temp._archive_name))
$(call sm-var-temp, _numobjs,      :=, $(words $(sm.this.objects)))
$(call sm-var-temp, _prompt,       :=, echo "$(sm.this.type): $(sm.var.temp._archive) ($(sm.var.temp._numobjs) objects)")

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

$(if $(sm.this.sources),\
   $(call sm-util-mkdir,$(dir $(sm.var.temp._out_lib)/$(sm.this.name))))

#$(info objects: $(words $(sm.this.objects)) for $(sm.this.name))
#$(info objects: $(wordlist 1,50,$(sm.this.objects)) for $(sm.this.name))

$(call sm-var-temp, _objs, :=)
$(call sm-var-temp, _flags_infile, :=, $(strip $(sm.this.link.flags.infile)))
ifeq ($(sm.var.temp._flags_infile),)
  sm.var.temp._flags_infile := true
endif

ifeq ($(sm.var.temp._flags_infile),true)
  $(call sm-util-mkdir,$(sm.out.tmp))
  $(shell echo $(sm.this.objects) > $(sm.out.tmp)/$(sm.this.name).objs)
   sm.var.temp._objs := @$(sm.out.tmp)/$(sm.this.name).objs
else
   sm.var.temp._objs := $(sm.this.objects)
endif

define _sm_rules
 $(sm.var.temp._archive): $(sm.this.objects)
	$(sm.var.Q)( $(sm.var.temp._prompt) )&&\
	( $(sm.var.temp._log) )&&\
	( $(sm.var.temp._ar) $(sm.var.temp._objs) || exit -1 )&&\
	( ranlib $(sm.var.temp._archive) )
endef
$(eval $(_sm_rules))

$(sm-var-temp-clean)
