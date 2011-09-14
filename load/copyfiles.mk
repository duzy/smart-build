# -*- makefile-gmake -*-
#	Copyright(c) 2009, by Zhan Xin-ming, duzy@duzy.info
#	

$(call sm-check-not-empty, sm.var.__copyfiles)
$(call sm-check-not-empty, sm.var.__copyfiles.to)

$(call sm-var-temp, _d, :=,$(call sm-to-relative-path,$(sm.var.__copyfiles.to)))

$(foreach v,$(sm.var.__copyfiles),\
   $(eval sm.this.depends.copyfiles += $(sm.var.temp._d)/$(notdir $v))\
   $(eval $(sm.var.temp._d)/$(notdir $v) : \
       $(call sm-to-relative-path,$(sm.this.dir)/$v) ; \
       @( echo file: $$@ )\
       && ([ -d $$(dir $$@) ] || mkdir -p $$(dir $$@))\
       && ($(CP) -u $$< $$@)))

$(sm-var-temp-clean)
