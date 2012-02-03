this := $(sm-this-dir)
$(eval \
  $$(call sm-load-module, $(this)/../smart.mk)\
  $$(call sm-load-module, $(this)/use.mk)\
 )
