#
$(call go-new-module, sync/atomic, pkg)

sm.this.sources := \
	asm_$(GOARCH).s\

ifeq ($(GOARCH),arm)
  sm.this.sources += asm_$(GOOS)_$(GOARCH).s
endif

$(go-build-this)
