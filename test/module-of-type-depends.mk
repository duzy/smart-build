#
#
####
test.case.module-of-type-depends-mk-loaded := 1
####
$(call test-check-undefined, sm.this.dir)
$(call sm-new-module, module-of-type-depends, depends)

sm.this.depends := $(sm.out)/module-of-type-depends-foo.txt

$(sm.out)/module-of-type-depends-foo.txt:
	mkdir -p $(@D) && echo foo > $@

$(sm-build-this)
