sm.tool.none := true

##
##
define sm.tool.none.config-module
$(eval \
  sm.this.type := none
 )
endef #sm.tool.none.config-module

## sm.var.source
## sm.var.intermediate (source -> intermediate)
define sm.tool.none.transform-single-source
$(info smart: none: $(sm.var.source) -> $(sm.var.intermediate))
endef #sm.tool.none.transform-single-source

##
##
define sm.tool.gcc.transform-intermediates
$(info smart: none: $($(sm._this).name))
endef #sm.tool.gcc.transform-intermediates
