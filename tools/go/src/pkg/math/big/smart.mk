#
$(call go-new-module, math/big, pkg)

OFILES=\
	arith_$(GOARCH).s\

GOFILES=\
	arith.go\
	arith_decl.go\
	int.go\
	nat.go\
	rat.go\

sm.this.sources := $(GOFILES) $(OFILES)

$(go-build-this)
