#

$(call sm-check-not-empty,sm.this.toolset,smart: 'sm.this.toolset' unknown)
$(call sm-check-empty,sm.tool.$(sm.this.toolset),smart: toolset '$(sm.this.toolset)' already defined)

sm.this.toolset := $(strip $(sm.this.toolset))
sm.temp._toolset_mk := $(sm.dir.buildsys)/tools/$(sm.this.toolset).mk

ifeq ($(wildcard $(sm.temp._toolset_mk)),)
  $(error smart: toolset '$(strip $3)' unsupported.)
endif

include $(sm.temp._toolset_mk)
################################################## default commands
ifndef sm.tool.$(sm.this.toolset).archive
  define sm.tool.$(sm.this.toolset).archive
    $(sm.tool.$(sm.this.toolset).cmd.ar) $(sm.args.target) $(sm.args.sources)
  endef
endif #sm.tool.$(sm.this.toolset).archive

##
## Provide default build commands if the toolset donnot have them defined.
define sm.fun.default-commands
$(eval \
  ifndef sm.tool.$(sm.this.toolset).compile.$(sm.var.temp._lang)
    define sm.tool.$(sm.this.toolset).compile.$(sm.var.temp._lang)
      $$(sm.tool.$(sm.this.toolset).cmd.$(sm.var.temp._lang)) \
        $$(sm.args.flags.0) -c -o $$(sm.args.target) $$(sm.args.sources)
    endef
  endif #sm.tool.$(sm.this.toolset).compile.$(sm.var.temp._lang)

  ifndef sm.tool.$(sm.this.toolset).dependency.$(sm.var.temp._lang)
    define sm.tool.$(sm.this.toolset).dependency.$(sm.var.temp._lang)
      $$(sm.tool.$(sm.this.toolset).cmd.$(sm.var.temp._lang)) \
        -MM -MT $$(sm.args.target) $$(sm.args.flags.0) $$(sm.args.sources) \
        > $$(sm.args.output)
    endef
  endif #sm.tool.$(sm.this.toolset).dependency.$(sm.var.temp._lang)

  ifndef sm.tool.$(sm.this.toolset).link.$(sm.var.temp._lang)
    define sm.tool.$(sm.this.toolset).link.$(sm.var.temp._lang)
      $$(sm.tool.$(sm.this.toolset).cmd.$(sm.var.temp._lang)) \
        $$(sm.args.flags.0) -o $$(sm.args.target) $$(sm.args.sources) $$(sm.args.flags.1)
    endef
  endif #sm.tool.$(sm.this.toolset).link.$(sm.var.temp._lang)

  ifndef sm.tool.$(sm.this.toolset).archive.$(sm.var.temp._lang)
    sm.tool.$(sm.this.toolset).archive.$(sm.var.temp._lang) = $$(sm.tool.$(sm.this.toolset).archive)
  endif #sm.tool.$(sm.this.toolset).archive.$(sm.var.temp._lang)
 )
endef #sm.fun.default-commands
################################################## end default commands

define sm.code.set-rule
sm-rule-$1-$(sm.var.temp._lang) = $$(eval sm.args.lang:=$(sm.var.temp._lang))$$(call sm-rule-$1)
endef #sm.code.set-rule

define sm.code.init-toolset-lang
  $(call sm.code.set-rule,compile)
  $(call sm.code.set-rule,dependency)
  $(call sm.code.set-rule,archive)
  $(call sm.code.set-rule,link)
  sm.toolset.for.$(sm.var.temp._lang) := $(sm.this.toolset)
  $(foreach _,$(sm.tool.$(sm.this.toolset).suffix.$(sm.var.temp._lang)),\
      $(eval sm.toolset.for.file$_ := $(sm.this.toolset)))
endef #sm.code.init-toolset-lang

## set variables sm.toolset.for.file.XXX, where XXX is a suffix such as '.cpp'
$(foreach sm.var.temp._lang, $(sm.tool.$(sm.this.toolset).langs),\
    $(sm.fun.default-commands)\
    $(eval $(call sm.code.init-toolset-lang,$(sm.var.temp._lang))))
