#
#
$(call test-check-undefined, sm.this.dir)
$(call sm-new-module, features-interpolate, none: depends)

sm.this.depends := $(sm.out.tmp)/features-interpolate.txt

define features-interpolate-vars
  SMART_TEST_FOO = foo
  SMART_TEST_BAR = bar
endef #features-interpolate-vars
$(call test-check-undefined,SMART_TEST_FOO)
$(call test-check-undefined,SMART_TEST_BAR)
$(call sm-interpolate, features-interpolate-vars, $(sm.out.tmp)/features-interpolate.txt, $(sm.this.dir)/foo.in)
$(call test-check-value-of,SMART_TEST_FOO,foo)
$(call test-check-value-of,SMART_TEST_BAR,bar)

$(sm-build-this)
