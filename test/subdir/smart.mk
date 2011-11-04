#
#
####
test.case.subdir-loaded := 1
####

$(call test-check-undefined,sm.this.dir)
$(call test-check-undefined,sm.this.name)
$(call test-check-undefined,sm.this.type)
$(call sm-new-module, subdir-foo, none)



$(sm-build-this)
