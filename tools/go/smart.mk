#

GOROOT ?= /store/open/go
GOOS ?= linux
GOARCH ?= amd64
GOROOT_FINAL ?= $(shell pwd)
#GOVERSION := $(shell $(go.root)/src/version.bash)
GOVERSION := smart.$(shell date +%Y-%m-%d)

ifndef GOOS
  $(error GOOS is empty)
endif
ifndef GOARCH
  $(error GOARCH is empty)
endif
ifndef GOROOT
  $(error GOROOT is empty)
endif

go.root := $(GOROOT)
go.args.module.clib := gcc:static
go.args.module.ccmd := gcc:exe
go.args.module.cmd := go:cmd
go.args.module.pkg := go:pkg
go.compile.flags.c := -Wall -Wno-sign-compare -Wno-missing-braces \
	-Wno-parentheses -Wno-unknown-pragmas -Wno-switch -Wno-comment \
	-Werror -fno-common
go.compile.flags.go :=
go.packages :=

ifndef go.root
  $(error go: GOROOT is empty)
endif

##
define go-init-module-clib
$(eval \
  sm.this.export.libdirs += $(sm.out.lib)
  sm.this.export.libs += $(sm.this.name)

  sm.this.includes += $(go.root)/include
  sm.this.compile.flags += $(go.compile.flags.c)

  ## don't install clibs
  sm.this.install_dir :=
 )
endef #go-init-module-clib

##
define go-init-module-ccmd
$(eval \
  sm.this.includes += $(go.root)/include
  sm.this.compile.flags += $(go.compile.flags.c)
 )
endef #go-init-module-ccmd

##
define go-init-module-cmd
$(eval \
  sm.this.includes += $(sm.out.pkg)
  sm.this.libdirs += $(sm.out.pkg)
  sm.this.compile.flags += $(go.compile.flags.go)
 )
endef #go-init-module-cmd

##
define go-init-module-pkg
$(eval \
  sm.this.includes += $(sm.out.pkg)
  sm.this.pack.flags +=
  go.packages += $(sm.this.name)
 )
endef #go-init-module-pkg

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
  sm.this.install_dir := $(GOROOT_FINAL)
  sm.this.gotype := $(strip $2)
  sm.this.compile.flags.asm +=
  sm.this.compile.flags.c +=
  sm.this.compile.flags.go +=
 )$(go-init-module-$(strip $2))
endef #go-new-module

## USE: mach bio 9 m
define go-build-this
$(call go-prepare-sources)\
$(go-use-basis-$(sm.this.gotype))\
$(call sm-build-this)\
$(eval #
  ifeq ($(sm.this.type),package)
    install-packages: _install-package-$(sm.this.name)
    _install-package-$(sm.this.name): $(sm.this.depends:goal-%=_install-package-%)
    _install-package-$(sm.this.name): install-package-$(sm.this.name)
  endif
 )
endef #go-build-this

##
define go-prepare-sources
$(eval \
  $(foreach _,$(sm.this.sources),
    ifeq ($(wildcard $(go.root)/$(sm.this.prefix)/$_),)
      $$(error "$(sm.this.prefix)/$_" no found)
    endif
    $(sm.this.prefix)/$_ : $(go.root)/$(sm.this.prefix)/$_
	@[[ -d $$(@D) ]] || mkdir -vp $$(@D)
	ln -sf $$< $$@ && [[ -f $$@ ]]
   )

  go.temp._yfiles := $(filter %.y, $(sm.this.sources))
  sm.this.sources := $(filter-out %.h %.y %.c.boot, $(sm.this.sources))
 )\
$(eval \
  ifdef go.temp._yfiles
    $(sm.this.prefix)/y.tab.h: $(go.temp._yfiles:%=$(sm.this.prefix)/%)
	cd $$(@D) && LANG=C LANGUAGE="en_US.UTF8" bison -v -y -d $$(<F)
    $(sm.this.prefix)/y.tab.c: $(sm.this.prefix)/y.tab.h
	cd $$(@D) && test -f $$(@F) && touch $$(@F)
  endif
 )
endef #go-prepare-sources

$(call sm-load-subdirs, src)

install-packages:
	@echo "installed-packages: $^"
