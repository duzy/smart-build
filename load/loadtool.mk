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
sm-rule-$2-$1 = $$(eval sm.args.lang:=$1)$$(call sm-rule-$2)
endef
define sm.code.init-toolset-lang
  $(call sm.code.set-rule,$1,compile)
  $(call sm.code.set-rule,$1,dependency)
  $(call sm.code.set-rule,$1,archive)
  $(call sm.code.set-rule,$1,link)
  sm.toolset.for.$1 := $(sm.this.toolset)
  $(foreach _,$(sm.tool.$(sm.this.toolset).$1.suffix),\
      $(eval sm.toolset.for.file$_ := $(sm.this.toolset)))
endef #sm.code.init-toolset-lang

$(foreach sm.var._temp._lang,$(sm.tool.$(sm.this.toolset).langs),\
    $(eval $(call sm.code.init-toolset-lang,$(sm.var._temp._lang))))

$(call sm-check-value, sm.toolset.for.file.cpp, $(sm.this.toolset), smart: $(sm.this.toolset) toolset ignores .cpp)
$(call sm-check-value, sm.toolset.for.file.c++, $(sm.this.toolset), smart: $(sm.this.toolset) toolset ignores .c++)
$(call sm-check-value, sm.toolset.for.file.cc,  $(sm.this.toolset), smart: $(sm.this.toolset) toolset ignores .cc)
$(call sm-check-value, sm.toolset.for.file.CC,  $(sm.this.toolset), smart: $(sm.this.toolset) toolset ignores .CC)
$(call sm-check-value, sm.toolset.for.file.C,   $(sm.this.toolset), smart: $(sm.this.toolset) toolset ignores .C)
$(call sm-check-value, sm.toolset.for.file.c,   $(sm.this.toolset), smart: $(sm.this.toolset) toolset ignores .c)
# $(call sm-check-value, sm.toolset.for.file.s,   $(sm.this.toolset), smart: $(sm.this.toolset) toolset ignores .s)
# $(call sm-check-value, sm.toolset.for.file.S,   $(sm.this.toolset), smart: $(sm.this.toolset) toolset ignores .S)
