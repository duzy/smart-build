#
$(call go-new-module, sync/atomic, pkg)

sm.this.sources := \
	asm_$(GOARCH).s\

$(go-build-this)
