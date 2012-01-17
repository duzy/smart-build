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
  #sm.this.export.libs += $(sm.out.lib)/lib$(sm.this.name).a
  sm.this.export.libdirs += $(sm.out.lib)
  sm.this.export.libs += $(sm.this.name)
 )
endef #go-init-module-clib

##
define go-init-module-ccmd
$(eval \
  #sm.this.libdirs += -L$(sm.out.lib)
  #sm.this.libs += mach bio 9 m
 )
endef #go-init-module-ccmd

##
define go-use-basis-ccmd
$(call sm-use, mach)\
$(call sm-use, bio)\
$(call sm-use, 9)
endef #go-use-basis-ccmd

##
define go-new-module
$(call sm-new-module, $1, $(go.args.module.$(strip $2)))\
$(eval \
  ifndef go.args.module.$(strip $2)
    $$(error module type "$(strip $2)" is unknown)
  endif
  sm.this.gotype := $(strip $2)
  sm.this.includes += $(go.root)/include
  sm.this.compile.flags += -Wall -Wno-sign-compare -Wno-missing-braces \
	-Wno-parentheses -Wno-unknown-pragmas -Wno-switch -Wno-comment \
	-Werror
  sm.this.compile.flags += -fno-common
 )$(go-init-module-$(strip $2))
endef #go-new-module

## USE: mach bio 9 m
define go-build-this
$(call go-prepare-sources)\
$(go-use-basis-$(sm.this.gotype))\
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
	ln -sf $$< $$@ || (echo "go: cannot link $$@" && false)
   )

  sm.this.sources := $(filter-out %.h, $(sm.this.sources))
 )
endef #go-prepare-sources

$(call sm-load-subdirs, src)
