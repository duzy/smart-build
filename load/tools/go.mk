# -*- mode: Makefile:gnu -*-
#	Copyright(c) 2009, 2010, 2011, 2012, by Zhan Xin-ming <code@duzy.info>
#	

##
##  sm.tool.go
##

## make sure that go.mk is included only once
$(call sm-check-origin, sm.tool.go, undefined)

sm.tool.go := true

## Languages supported by this toolset, the order is significant,
## the order defines the priority of linker
sm.tool.go.langs := go c asm
sm.tool.go.suffix.c   := .c
sm.tool.go.suffix.go  := .go
sm.tool.go.suffix.asm := .s .S

## Compilation output files(objects) suffixes.
sm.tool.go.suffix.intermediate.c   = .$($(sm._this).o)
sm.tool.go.suffix.intermediate.c++ = .$($(sm._this).o)
sm.tool.go.suffix.intermediate.go  = .$($(sm._this).o)
sm.tool.go.suffix.intermediate.asm = .$($(sm._this).o)
sm.tool.go.o.x86_64 := 6
sm.tool.go.o.i386   := 8
sm.tool.go.o.arm    := 5

## Target link output file suffix.
sm.tool.go.suffix.target.win32.package := .a
sm.tool.go.suffix.target.win32.command := .exe
sm.tool.go.suffix.target.linux.package := .a
sm.tool.go.suffix.target.linux.command :=

## Variant Specific Flags
sm.tool.go.flags.compile.variant.debug   :=
sm.tool.go.flags.compile.variant.release :=
sm.tool.go.flags.link.variant.debug   :=
sm.tool.go.flags.link.variant.release :=
sm.tool.go.flags.pack.variant.debug   :=
sm.tool.go.flags.pack.variant.release :=

## OS Specific Flags
sm.tool.go.flags.compile.os.linux :=
sm.tool.go.flags.compile.os.win32 :=
sm.tool.go.flags.link.os.linux :=
sm.tool.go.flags.link.os.win32 :=
sm.tool.go.flags.pack.os.linux :=
sm.tool.go.flags.pack.os.win32 :=

## Target Type Specific Flags
sm.tool.go.flags.compile.type.package :=
sm.tool.go.flags.compile.type.command :=
sm.tool.go.flags.link.type.package :=
sm.tool.go.flags.link.type.command :=

sm.tool.go.root := $(GOROOT)
ifndef sm.tool.go.root
  sm.tool.go.root := $(patsubst %/,%,$(dir $(shell dirname `which gomake`)))
endif
ifndef sm.tool.go.root
  sm.tool.go.root := $(patsubst %/,%,$(dir $(shell dirname `which go`)))
endif
ifndef sm.tool.go.root
  $(error smart: go: cannot determine the GOROOT)
endif

## Language Specific Flags
sm.tool.go.flags.compile.lang.c   := -FVw -I$(sm.tool.go.root)/pkg/linux_amd64
sm.tool.go.flags.compile.lang.go  :=
sm.tool.go.flags.compile.lang.asm :=
sm.tool.go.flags.compile.gcc :=

##
## Compile Commands
define sm.tool.go.command.compile.c
$($(sm._this).o)c $(sm.var.flags) -o $(sm.var.intermediate) $(sm.var.source.computed)
endef #sm.tool.go.command.compile.c

define sm.tool.go.command.compile.go
$($(sm._this).o)g $(sm.var.flags) -o $(sm.var.intermediate) $$$$^
endef #sm.tool.go.command.compile.go

define sm.tool.go.command.compile.asm
$($(sm._this).o)a $(sm.var.flags) -o $(sm.var.intermediate) $(sm.var.source.computed)
endef #sm.tool.go.command.compile.asm

##
##
define sm.tool.go.command.link
$($(sm._this).o)l $(sm.var.flags) -o $(sm.var.target) $(sm.var.intermediates) $(sm.var.loadlibs)
endef #sm.tool.go.command.link

##
##
define sm.tool.go.command.pack
gopack grc $(sm.var.target) $(sm.var.intermediates)
endef #sm.tool.go.command.pack

##
##
define sm.tool.go.args.types
$(filter-out -%, $($(sm._this).toolset.args))
endef #sm.tool.go.args.types

##
##
define sm.tool.go.config-module
$(call sm-check-not-empty, \
    sm.os.name \
    sm.config.variant \
 ,,go:)\
$(eval #
   sm.this.gen_deps := true
   sm.this.type := $(firstword $(sm.this.toolset.args))
 )\
$(eval #
   ifeq ($(sm.this.type),pkg)
     sm.this.type := package
   endif
   ifeq ($(sm.this.type),cmd)
     sm.this.type := command
   endif
 )\
$(eval #
   sm.this.suffix := $(sm.tool.go.suffix.target.$(sm.os.name).$(sm.this.type))
   sm.this.compile.flags := $(sm.tool.go.flags.compile.variant.$(sm.config.variant))
   sm.this.compile.flags += $(sm.tool.go.flags.compile.os.$(sm.os.name))
   sm.this.compile.flags += $(sm.tool.go.flags.compile.type.$(sm.this.type))
   sm.this.compile.flags.c   := $(sm.tool.go.flags.compile.lang.c)
   sm.this.compile.flags.go  := $(sm.tool.go.flags.compile.lang.go)
   sm.this.compile.flags.asm := $(sm.tool.go.flags.compile.lang.asm)
   sm.this.compile.flags.gcc := $(sm.tool.go.flags.compile.gcc)
   sm.this.link.flags := $(sm.tool.go.flags.link.variant.$(sm.config.variant))
   sm.this.link.flags += $(sm.tool.go.flags.link.os.$(sm.os.name))
   sm.this.link.flags += $(sm.tool.go.flags.link.type.$(sm.this.type))
   sm.this.pack.flags := $(sm.tool.go.flags.pack.variant.$(sm.config.variant))
   sm.this.pack.flags += $(sm.tool.go.flags.pack.os.$(sm.os.name))
   sm.this.pack.flags += $(sm.tool.go.flags.pack.type.$(sm.this.type))
   sm.this.o := $(sm.tool.go.o.$(sm.config.machine))
   ifeq ($(sm.this.type),package)
     sm.this.export.compile.flags := -I$(sm.out.pkg)
     sm.this.export.link.flags := -L$(sm.out.pkg)
   endif
 )
endef #sm.tool.go.config-module

##
##  (source -> intermediate)
define sm.tool.go.transform-single-source
$(call sm-check-not-empty, \
    sm._this $(sm._this).name $(sm._this).out $(sm._this).out.inter \
    sm.var.source \
    sm.var.source.computed \
    sm.var.source.type \
    sm.var.source.lang \
    sm.var.source.suffix \
    sm.var.intermediate \
 ,,go:)\
$(eval #
  ifdef sm.tool.go.transform-$(sm.var.source.type)-source
     $$(sm.tool.go.transform-$(sm.var.source.type)-source)
  else
     $$(sm.tool.go.transform-goc-source)
  endif
 )
endef #sm.tool.go.transform-single-source

##
## .go(cgo) files
define sm.tool.go.transform-cgo-source
$(eval #
  sm.var.intermediate.cgo := $($(sm._this).out.inter)/_cgo
  sm.var.intermediate.cgo_export.h := $$(sm.var.intermediate.cgo)/_cgo_export.h
  sm.var.intermediate.cgo_import.c := $$(sm.var.intermediate.cgo)/_cgo_import.c
  sm.var.intermediate.cgo_import.o := $$(sm.var.intermediate.cgo)/_cgo_import.$($(sm._this).o)
 )\
$(eval #
  sm.var.has_cgo_rules := $(filter $(sm.var.intermediate.cgo_import.o),$($(sm._this).intermediates))
  ifndef sm.var.has_cgo_rules
    sm.var._cgo1_o.libs :=
    $$(call sm.fun.append-items-with-fix, sm.var._cgo1_o.libs, \
        $($(sm._this).used.libdirs), -L, , -% -Wl%)
    $$(call sm.fun.append-items-with-fix, sm.var._cgo1_o.libs, \
        $($(sm._this).used.libs), -l, , -% -Wl% %.a %.so %.lib %.dll)
  endif
 )\
$(eval #
  $(sm.var.intermediate.cgo_export.h) : $(sm.var.source.computed)

  ifndef sm.var.sources.$(sm.var.source.type)
    $$(error no sources of type "$(sm.var.source.type)")
  endif

  ifndef sm.var.has_cgo_rules
    sm.var.cgo_intermediates := \
        $(sm.var.intermediate.cgo_import.c)\
        $(sm.var.intermediate.cgo)/_cgo_defun.c \
        $(sm.var.intermediate.cgo)/_cgo_gotypes.go \
        $(sm.var.sources.$(sm.var.source.type):%.go=$(sm.var.intermediate.cgo)/go_%.cgo1.go) \

    sm.var.cgo_main_o := $(sm.var.intermediate.cgo)/_cgo_main.o
    sm.var.gcc_intermediates := \
        $(sm.var.intermediate.cgo)/_cgo_main.c \
        $(sm.var.intermediate.cgo)/_cgo_export.c \
        $(sm.var.sources.$(sm.var.source.type):%.go=$(sm.var.intermediate.cgo)/go_%.cgo2.c) \

    $(sm._this).cgo_flags := $(sm.var.intermediate.cgo)/_cgo_flags
    $(sm._this).compile.flags.c += -I$($(sm._this).out.inter)
    $(sm._this).compile.flags.gcc += -fPIC -I$($(sm._this).out.inter)
    $(sm._this).link.flags.gcc +=
    $(sm._this).unterminated.cgo.goc += $$(sm.var.cgo_intermediates)
    $(sm._this).unterminated.cgo.gcc += $$(sm.var.gcc_intermediates)
    $(sm._this).intermediates += $(sm.var.intermediate.cgo_import.o)

    $$(sm.var.cgo_intermediates) : $(sm.var.intermediate.cgo_export.h)
    $$(sm.var.gcc_intermediates) : $(sm.var.intermediate.cgo_export.h)
    $(sm.var.intermediate.cgo_export.h):
	@[[ -d $$(@D) ]] || mkdir -p $$(@D)
	@[[ -d $(sm.var.intermediate.cgo) ]] || mkdir -p $(sm.var.intermediate.cgo)
	@echo "cgo: $$@"
	cgo -objdir="$(sm.var.intermediate.cgo)" -- $$^
	@[[ -f $$@ ]] || ( echo "cgo: $$@ not generated" && false )
    $(sm.var.intermediate.cgo_import.c) : $(sm.var.intermediate.cgo)/_cgo1.o
	@[[ -d $$(@D) ]] || mkdir -p $$(@D)
	cgo -dynimport $(sm.var.intermediate.cgo)/_cgo1.o > $$@_ && mv -f $$@_ $$@
	@[[ -f $$@ ]] || ( echo "cgo: $$@ not generated" && false )
    $(sm.var.intermediate.cgo)/_cgo1.o: $$(sm.var.gcc_intermediates:%.c=%.o)
	@[[ -d $$(@D) ]] || mkdir -p $$(@D)
	gcc -g -fPIC -O2 -o $$@ $$^ $(sm.var._cgo1_o.libs)
  endif
 )
endef #sm.tool.go.transform-cgo-source

##
## .c(goc) generated by cgo
define sm.tool.go.transform-cgo.goc-source
$(eval #
  sm.var.source.computed := $(sm.var.source)
  sm.var.intermediate := $(basename $(sm.var.source)).$($(sm._this).o)
 )\
$(sm.tool.go.transform-goc-source)
endef #sm.tool.go.transform-cgo.goc-source

##
## .c(gcc) files generated by cgo
define sm.tool.go.transform-cgo.gcc-source
$(eval #
  sm.var.source.computed := $(sm.var.source)
  sm.var.intermediate := $(basename $(sm.var.source)).o
 )\
$(sm.tool.go.transform-gcc-source)\
$(eval #
  ifeq ($(sm.var.intermediate),$(sm.var.cgo_main_o))
    $(sm._this).intermediates := $(filter-out $(sm.var.cgo_main_o),$($(sm._this).intermediates))
  endif
 )
endef #sm.tool.go.transform-cgo.gcc-source

##
## .go and .c(goc) files
define sm.tool.go.transform-goc-source
$(eval #
  ifeq ($(sm.var.source.lang),go)
    sm.var.intermediate.go := $($(sm._this).out.inter)/_go_.$($(sm._this).o)
  endif
 )\
$(eval #
  ifeq ($(sm.var.source.lang),go)
    $(sm.var.intermediate.go) : $(sm.var.source.computed)
    ifeq ($(filter $(sm.var.intermediate.go),$($(sm._this).intermediates)),)
      $(sm._this).intermediates += $(sm.var.intermediate.go)
      sm.var.intermediate := $(sm.var.intermediate.go)
    endif
  endif

  sm.var.flags :=
  sm.var.flags += $($(sm._this).used.defines)
  sm.var.flags += $($(sm._this).used.defines.$(sm.var.source.lang))
  sm.var.flags += $($(sm._this).used.compile.flags)
  sm.var.flags += $($(sm._this).used.compile.flags.$(sm.var.source.lang))
  sm.var.flags += $($(sm._this).defines)
  sm.var.flags += $($(sm._this).defines.$(sm.var.source.lang))
  sm.var.flags += $($(sm._this).compile.flags)
  sm.var.flags += $($(sm._this).compile.flags.$(sm.var.source.lang))

  $$(call sm.fun.append-items-with-fix, sm.var.flags, \
         $($(sm._this).includes)\
         $($(sm._this).used.includes)\
         $($(sm.var.tool).includes)\
        , -I, , -%)

  $$(call sm-remove-duplicates,sm.var.flags)

  sm.temp._flagsfile := $$(call sm.fun.shift-flags-to-file, sm.var.flags, compile.$(sm.var.source.lang), $($(sm._this).compile.flags.infile))
  ifdef sm.temp._flagsfile
    $(sm.var.intermediate) $(sm.var.intermediate).d : $$(sm.temp._flagsfile)
    sm.var.flags := @$$(sm.temp._flagsfile)
  endif

  ifneq ($(sm.var.source.lang),go)
    sm.var.flags += $(strip $($(sm._this).compile.flags-$(sm.var.source)))
    $$(call sm-remove-duplicates,sm.var.flags)
  endif

  sm.var.command := $$(sm.tool.go.command.compile.$(sm.var.source.lang))
 )\
$(eval #
  ifneq ($(sm.var.source.lang),go)
    $(sm._this).intermediates += $(sm.var.intermediate)
  endif
  $(sm.var.intermediate) : $(sm.var.source.computed)
	@[[ -d $$(@D) ]] || mkdir -p $$(@D)
	$(call sm.fun.wrap-rule-commands, go: $(sm.var.source.lang), $(sm.var.command))
 )
endef #sm.tool.go.transform-goc-source

##
## .c files compiled with gcc
define sm.tool.go.transform-gcc-source
$(eval #
  ifneq ($(sm.tool.gcc),true)
    include $(sm.dir.buildsys)/tools/gcc.mk
    ifneq ($$(flavor sm.tool.gcc.transform-source-c),recursive)
      $$(error go: invalid sm.tool.gcc.transform-source-c)
    endif
  endif

  sm.var.specific_flags := $($(sm._this).compile.flags.gcc)
  ifneq ($(wildcard $($(sm._this).cgo_flags)),)
    ifndef $(sm._this).cgo_flags.included
      include $($(sm._this).cgo_flags)
      sm.var.specific_flags += $$(_CGO_CFLAGS)
      $(sm._this).cgo_flags.included := true
    endif
  endif
 )\
$(sm.tool.gcc.transform-source-c)\
$(eval #
  sm.var.specific_flags :=
 )
endef #sm.tool.go.transform-gcc-source

##
##
define sm.tool.go.transform-intermediates
$(call sm-check-not-empty, sm._this \
  $(sm._this).name \
  $(sm._this).lang \
  $(sm._this).type \
  $(sm._this).intermediates \
 ,,go:)\
$(eval #
  sm.var.intermediates := $($(sm._this).intermediates)
  sm.var.target :=
  sm.var.target.link :=
  sm.var.flags :=
  ifeq ($($(sm._this).type),package)
    sm.var.target := $(patsubst $(sm.top)/%,%,$(sm.out.pkg))/$($(sm._this).name)$($(sm._this).suffix)
    sm.var.flags += $($(sm._this).used.archive.flags)
    sm.var.flags += $($(sm._this).used.archive.flags.$($(sm._this).lang))
    sm.var.flags += $($(sm._this).archive.flags)
    sm.var.flags += $($(sm._this).archive.flags.$($(sm._this).lang))
  else
    sm.var.target := $(patsubst $(sm.top)/%,%,$(sm.out.bin))/$($(sm._this).name)$($(sm._this).suffix)
    sm.var.flags += $($(sm._this).used.link.flags)
    sm.var.flags += $($(sm._this).used.link.flags.$($(sm._this).lang))
    sm.var.flags += $($(sm._this).link.flags)
    sm.var.flags += $($(sm._this).link.flags.$($(sm._this).lang))
  endif
  sm.var.loadlibs :=
 )\
$(call sm.fun.append-items-with-fix, sm.var.loadlibs, \
      $($(sm._this).libdirs) \
      $($(sm._this).used.libdirs)\
      $($(sm.var.tool).libdirs)\
     , -L, , -% -Wl%)\
$(call sm.fun.append-items-with-fix, sm.var.loadlibs, \
      $($(sm._this).libs) \
      $($(sm._this).used.libs)\
      $($(sm.var.tool).libs)\
     , -l, , -% -Wl% %.a %.so %.lib %.dll)\
$(call sm-remove-duplicates,sm.var.flags)\
$(call sm-remove-duplicates,sm.var.loadlibs)\
$(eval #
  sm.temp._flagsfile := $$(call sm.fun.shift-flags-to-file, sm.var.flags, link, $($(sm._this).link.flags.infile))
  ifdef sm.temp._flagsfile
    $(sm.var.intermediate) : $$(sm.temp._flagsfile)
    sm.var.flags := @$$(sm.temp._flagsfile)
  endif

  sm.temp._flagsfile := $$(call sm.fun.shift-flags-to-file, sm.var.intermediates, intermediates.link, $($(sm._this).link.intermediates.infile))
  ifdef sm.temp._flagsfile
    $(sm.var.intermediate) : $$(sm.temp._flagsfile)
    sm.var.intermediates.preq := $(sm.var.intermediates)
    sm.var.intermediates := @$$(sm.temp._flagsfile)
  else
    sm.var.intermediates.preq = $(sm.var.intermediates)
  endif

  sm.temp._flagsfile := $$(call sm.fun.shift-flags-to-file, sm.var.loadlibs, libs.link, $($(sm._this).libs.infile))
  ifdef sm.temp._flagsfile
    $(sm.var.intermediate) : $$(sm.temp._flagsfile)
    sm.var.loadlibs := @$$(sm.temp._flagsfile)
  endif

  ifeq ($($(sm._this).type),package)
    sm.var.command := $(sm.tool.go.command.pack)
  else
    sm.var.command := $(sm.tool.go.command.link)
  endif
 )\
$(eval #
  $(sm._this).targets += $(sm.var.target)
  $(sm.var.target) : $(sm.var.intermediates.preq)
	@[[ -d $$(@D) ]] || mkdir -p $$(@D)
	$(call sm.fun.wrap-rule-commands, go, $(sm.var.command))
 )
endef #sm.tool.go.transform-intermediates
