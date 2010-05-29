# -*- makefile-gmake -*-
#	Copyright(c) 2009, by Zhan Xin-ming, duzy@duzy.info
#	

$(call sm-check-not-empty, sm.var.__copyfiles)
$(call sm-check-not-empty, sm.var.__copyfiles.to)

#sm.module.depends.copy := $(sm.module.depends.copy)

$(call sm-var-temp, _d, :=,$(call sm-to-relative-path,$(sm.var.__copyfiles.to)))

$(foreach v,$(sm.var.__copyfiles),\
   $(eval f:=$(notdir $v))\
   $(eval sm.module.depends.copy += $(sm.var.temp._d)/$f)\
   $(eval $(sm.var.temp._d)/$f : $(call sm-to-relative-path,$(sm.module.dir)/$v) ; \
       @( echo file: $$@ )\
       && ([ -d $$(dir $$@) ] || mkdir -p $$(dir $$@))\
       && ($(CP) -u $$< $$@)))

$(sm-var-temp-clean)
