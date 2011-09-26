#

$(call sm-check-not-empty,sm.this.toolset,smart: 'sm.this.toolset' unknown)
$(call sm-check-empty,sm.tool.$(sm.this.toolset),smart: toolset '$(sm.this.toolset)' already defined)

sm._toolset.mk := $(sm.dir.buildsys)/tools/$(strip $(sm.this.toolset)).mk

ifeq ($(wildcard $(sm._toolset.mk)),)
  $(error smart: toolset '$(strip $3)' unsupported.)
endif

include $(sm._toolset.mk)
sm._toolset.mk :=

define sm.code.set-rule
sm-rule-$1-$(sm.var.temp._lang) = $$(eval sm.args.lang:=$(sm.var.temp._lang))$$(call sm-rule-$1)
endef #sm.code.set-rule
define sm.code.init-toolset-lang
  $(call sm.code.set-rule,compile)
  $(call sm.code.set-rule,dependency)
  $(call sm.code.set-rule,archive)
  $(call sm.code.set-rule,link)
  sm.toolset.for.$(sm.var.temp._lang) := $(sm.this.toolset)
  $(foreach _,$(sm.tool.$(sm.this.toolset).$(sm.var.temp._lang).suffix),\
      $(eval sm.toolset.for.file$_ := $(sm.this.toolset)))
endef #sm.code.init-toolset-lang

## set variables sm.toolset.for.file.XXX, where XXX is a suffix such as '.cpp'
$(foreach sm.var.temp._lang,$(sm.tool.$(sm.this.toolset).langs),\
    $(eval $(call sm.code.init-toolset-lang,$(sm.var.temp._lang))))

# $(call sm-check-value, sm.toolset.for.file.cpp, $(sm.this.toolset), smart: $(sm.this.toolset) toolset ignores .cpp)
# $(call sm-check-value, sm.toolset.for.file.c++, $(sm.this.toolset), smart: $(sm.this.toolset) toolset ignores .c++)
# $(call sm-check-value, sm.toolset.for.file.cc,  $(sm.this.toolset), smart: $(sm.this.toolset) toolset ignores .cc)
# $(call sm-check-value, sm.toolset.for.file.CC,  $(sm.this.toolset), smart: $(sm.this.toolset) toolset ignores .CC)
# $(call sm-check-value, sm.toolset.for.file.C,   $(sm.this.toolset), smart: $(sm.this.toolset) toolset ignores .C)
# $(call sm-check-value, sm.toolset.for.file.c,   $(sm.this.toolset), smart: $(sm.this.toolset) toolset ignores .c)
# # $(call sm-check-value, sm.toolset.for.file.s,   $(sm.this.toolset), smart: $(sm.this.toolset) toolset ignores .s)
# # $(call sm-check-value, sm.toolset.for.file.S,   $(sm.this.toolset), smart: $(sm.this.toolset) toolset ignores .S)
