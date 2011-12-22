#

$(call sm-check-not-empty,sm.this.toolset,smart: 'sm.this.toolset' unknown)
$(call sm-check-empty,sm.tool.$(sm.this.toolset),smart: toolset '$(sm.this.toolset)' already defined)

sm.this.toolset := $(strip $(sm.this.toolset))
sm.temp._toolset_mk := $(sm.dir.buildsys)/tools/$(sm.this.toolset).mk

ifeq ($(wildcard $(sm.temp._toolset_mk)),)
  $(error smart: toolset '$(strip $3)' unsupported.)
endif

sm.tool.$(sm.this.toolset).args := $(strip $(sm.this.toolset.args))
include $(sm.temp._toolset_mk)
