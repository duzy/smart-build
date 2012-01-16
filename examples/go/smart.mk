#

go.root := $(GOROOT)

go.args.module.clib := gcc:static
go.args.module.ccmd := gcc:exe

ifndef go.root
  $(error go: GOROOT is empty)
endif

##
define go-init-module-clib
$(eval \
  sm.this.export.libs += $(sm.out.lib)/lib$(sm.this.name).a
 )
endef #go-init-module-clib

##
define go-init-module-ccmd
$(call sm-use, mach)\
$(eval \
  sm.this.libs += mach bio 9 m
 )
endef #go-init-module-ccmd

##
define go-new-module
$(call sm-new-module, $1, $(go.args.module.$(strip $2)))\
$(eval \
  ifndef go.args.module.$(strip $2)
    $$(error module type "$(strip $2)" is unknown)
  endif
  sm.this.includes := $(go.root)/include  
 )$(go-init-module-$(strip $2))
endef #go-new-module

##
define go-build-this
$(call go-prepare-sources)\
$(call sm-build-this)
endef #go-build-this

##
define go-prepare-sources
$(eval \
  go.temp._prefix := $(sm.this.dir:$(sm.top)/%=%)
 )\
$(eval \
  $(foreach _,$(sm.this.sources),
    ifeq ($(wildcard $(go.root)/$(go.temp._prefix)/$_),)
      $$(error "$(go.temp._prefix)/$_" no found)
    endif
    $(go.temp._prefix)/$_ : $(go.root)/$(go.temp._prefix)/$_
	@echo "go: link: $$@..." &&\
	([[ -d $$(@D) ]] || mkdir -vp $$(@D)) &&\
	ln -s $$< $$@
   )

  sm.this.sources := $(filter-out %.h, $(sm.this.sources))
 )
endef #go-prepare-sources

$(call sm-load-subdirs, src)
