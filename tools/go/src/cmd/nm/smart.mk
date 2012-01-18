#
$(call go-new-module, 6nm, ccmd)

sm.this.sources := \
	nm.c\

$(go-build-this)
