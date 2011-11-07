#
#
####
test.case.module-of-type-none-mk-loaded := 1
####

$(call test-check-undefined, sm.this.dir)
########## case in
$(call sm-new-module, module-of-type-none, none)
########## case out
$(call test-check-defined, sm.this.dir)

########## case in
$(sm-build-this)
########## case out
