this := $(sm-this-dir)
$(eval \
  $$(call sm-load-module, $(this)/../static/smart.mk)\
  $$(call sm-load-module, $(this)/test.mk)\
 )
