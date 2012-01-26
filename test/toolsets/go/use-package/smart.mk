this := $(sm-this-dir)
$(eval \
  $$(call sm-load-module, $(this)/../package/smart.mk)\
  $$(call sm-load-module, $(this)/test.mk)\
 )