#

$(call sm-check-not-empty,sm.this.toolset,smart: 'sm.this.toolset' unknown)
$(call sm-check-empty,sm.tool.$(sm.this.toolset),smart: toolset '$(sm.this.toolset)' already defined)

sm._toolset.mk := $(sm.dir.buildsys)/tools/$(strip $(sm.this.toolset)).mk

ifeq ($(wildcard $(sm._toolset.mk)),)
  $(error smart: toolset '$(strip $3)' unsupported.)
endif

include $(sm._toolset.mk)
sm._toolset.mk :=

define sm.code.init-toolset-lang
  sm.rule.compile.$1 = $$(call sm.rule.compile,$1,$$(strip $$1),$$(strip $$2),$$(strip $$3))
  sm.rule.dependency.$1 = $$(call sm.rule.dependency,$1,$$(strip $$1),$$(strip $$2),$$(strip $$3),$$(strip $$4))
  sm.rule.archive.$1 = $$(call sm.rule.archive,$1,$$(strip $$1),$$(strip $$2),$$(strip $$3),$$(strip $$4))
  sm.rule.link.$1 = $$(call sm.rule.link,$1,$$(strip $$1),$$(strip $$2),$$(strip $$3),$$(strip $$4),$$(strip $$5))
  sm.toolset.for.$1 := $(sm.this.toolset)
  $(foreach s,$(sm.tool.$(sm.this.toolset).$1.suffix),\
      $(eval sm.toolset.for.file$s := $(sm.this.toolset)))
endef

$(foreach sm._var._temp._lang,$(sm.tool.$(sm.this.toolset).langs),\
    $(eval $(call sm.code.init-toolset-lang,$(sm._var._temp._lang))))

$(call sm-check-value, sm.toolset.for.file.cpp, $(sm.this.toolset), smart: $(sm.this.toolset) toolset ignores .cpp)
$(call sm-check-value, sm.toolset.for.file.c++, $(sm.this.toolset), smart: $(sm.this.toolset) toolset ignores .c++)
$(call sm-check-value, sm.toolset.for.file.cc,  $(sm.this.toolset), smart: $(sm.this.toolset) toolset ignores .cc)
$(call sm-check-value, sm.toolset.for.file.CC,  $(sm.this.toolset), smart: $(sm.this.toolset) toolset ignores .CC)
$(call sm-check-value, sm.toolset.for.file.C,   $(sm.this.toolset), smart: $(sm.this.toolset) toolset ignores .C)
$(call sm-check-value, sm.toolset.for.file.c,   $(sm.this.toolset), smart: $(sm.this.toolset) toolset ignores .c)
# $(call sm-check-value, sm.toolset.for.file.s,   $(sm.this.toolset), smart: $(sm.this.toolset) toolset ignores .s)
# $(call sm-check-value, sm.toolset.for.file.S,   $(sm.this.toolset), smart: $(sm.this.toolset) toolset ignores .S)
