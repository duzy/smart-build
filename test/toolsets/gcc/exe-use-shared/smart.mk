this := $(sm-this-dir)
$(eval \
  $$(call sm-load-module, ../shared/smart.mk)\
  $$(call sm-load-module, test.mk)\
 )
