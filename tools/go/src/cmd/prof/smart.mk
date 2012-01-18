#
$(call go-new-module, 6prof, ccmd)

sm.this.sources := \
	main.c\

$(go-build-this)
