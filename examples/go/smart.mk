#

go.args.module.clib := gcc:static

##
define go-new-module
$(call sm-new-module, $1, $(go.args.module.$(strip $2)))
endef #go-new-module

##
define go-build-this
$(call sm-build-this)
endef #go-build-this

$(call sm-load-subdirs, src)
