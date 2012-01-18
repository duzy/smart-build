#
$(call go-new-module, gopack, ccmd)

sm.this.sources := ar.c
#sm.this.includes += $(go.root)/src/cmd/6c

$(go-build-this)
