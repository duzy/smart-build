#
#
####
test.case.another-module-mk-loaded := 1
####

$(call test-check-undefined, sm.this.dir)
########## case in
$(call sm-new-module, another-foobar, none)
########## case out
$(call test-check-defined, sm.this.dir)

########## case in
$(sm-build-this)
########## case out
