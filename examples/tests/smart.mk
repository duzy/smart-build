# include foobar.mk
# include foo.mk
$(call sm-load-module, foobar.mk)
$(call sm-load-module, foo.mk)
