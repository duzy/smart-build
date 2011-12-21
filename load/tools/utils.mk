sm.tool.utils := true

##
##
define sm.tool.utils.config-module
$(eval \
  sm.this.type := none
 )
endef #sm.tool.utils.config-module

## sm.var.source
## sm.var.source.computed
## sm.var.intermediate (source -> intermediate)
define sm.tool.utils.transform-single-source
$(foreach _, $($(sm._this).toolset.args), $(call sm.tool.utils.$_-single-source))
endef #sm.tool.utils.transform-single-source

define sm.tool.utils.copy-single-source
$(eval \
  sm.temp._dest_file := $(subst //,/,$($(sm._this).destination)/$(sm.var.source))
  sm.temp._mode := $(strip $($(sm._this).chmod))
 )\
$(eval \
  ifndef $(sm._this).targets.copied
    $(sm._this).targets.copied := $(sm.temp._dest_file)
  else
    $(sm._this).targets.copied += $(sm.temp._dest_file)
  endif
  $(sm.temp._dest_file): $(sm.var.source.computed)
	@( echo smart: copy: $$@ ) &&\
	 ([ -d $$(dir $$@) ] || mkdir -p $$(dir $$@)) &&\
	 (cp -u $$< $$@) && $(if $(sm.temp._mode), (chmod $(sm.temp._mode) $$@), true)
 )
endef #sm.tool.utils.copy-single-source

##
##
define sm.tool.utils.transform-intermediates
$(eval \
  $(sm._this).targets := copy-$($(sm._this).name)
  copy-$($(sm._this).name): $($(sm._this).targets.copied)
 )
endef #sm.tool.utils.transform-intermediates
