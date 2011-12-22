# -*- mode: Makefile:gnu -*-
#	Copyright(c) 2009-2010, by Zhan Xin-ming <code@duzy.info>
#	

##
##  sm.tool.gcc
##

## make sure that gcc.mk is included only once
$(call sm-check-origin, sm.tool.gcc, undefined)

sm.tool.gcc := true

## Languages supported by this toolset, the order is significant,
## the order defines the priority of linker
sm.tool.gcc.langs := c++ go c asm
sm.tool.gcc.suffix.c := .c
sm.tool.gcc.suffix.c++ := .cpp .c++ .cc .CC .C
sm.tool.gcc.suffix.go := .go
sm.tool.gcc.suffix.asm := .s .S

## Compilation output files(objects) suffixes.
sm.tool.gcc.suffix.intermediate.c := .o
sm.tool.gcc.suffix.intermediate.c++ := .o
sm.tool.gcc.suffix.intermediate.go := .o
sm.tool.gcc.suffix.intermediate.asm := .o

## Target link output file suffix.
sm.tool.gcc.suffix.target.static.win32 := .a
sm.tool.gcc.suffix.target.shared.win32 := .so
sm.tool.gcc.suffix.target.exe.win32 := .exe
sm.tool.gcc.suffix.target.t.win32 := .test.exe
sm.tool.gcc.suffix.target.depends.win32 :=
sm.tool.gcc.suffix.target.static.linux := .a
sm.tool.gcc.suffix.target.shared.linux := .so
sm.tool.gcc.suffix.target.exe.linux :=
sm.tool.gcc.suffix.target.t.linux := .test
sm.tool.gcc.suffix.target.depends.linux :=

sm.tool.gcc.flags.compile.variant.debug := -g -ggdb
sm.tool.gcc.flags.compile.variant.release := -O3
sm.tool.gcc.flags.link.variant.debug := -g -ggdb
sm.tool.gcc.flags.link.variant.release := -O3

sm.tool.gcc.flags.compile.os.linux :=
sm.tool.gcc.flags.compile.os.win32 := -mwindows
sm.tool.gcc.flags.link.os.linux :=
sm.tool.gcc.flags.link.os.win32 := -mwindows \
  -Wl,--enable-runtime-pseudo-reloc \
  -Wl,--enable-auto-import \

##
## Compile Commands
define sm.tool.gcc.command.compile.c
gcc $(sm.var.flags) -o $(sm.var.intermediate) -c $(sm.var.source.computed)
endef #sm.tool.gcc.command.compile.c

define sm.tool.gcc.command.compile.c++
g++ $(sm.var.flags) -o $(sm.var.intermediate) -c $(sm.var.source.computed)
endef #sm.tool.gcc.command.compile.c++

define sm.tool.gcc.command.compile.go
gccgo $(sm.var.flags) -o $(sm.var.intermediate) -c $(sm.var.source.computed)
endef #sm.tool.gcc.command.compile.go

define sm.tool.gcc.command.compile.asm
gcc $(sm.var.flags) -o $(sm.var.intermediate) -c $(sm.var.source.computed)
endef #sm.tool.gcc.command.compile.asm

##
##
define sm.tool.gcc.command.link.c
gcc $(sm.var.flags) -o $(sm.var.target) $(sm.var.intermediates) $(sm.var.loadlibs)
endef #sm.tool.gcc.command.link.c

define sm.tool.gcc.command.link.c++
g++ $(sm.var.flags) -o $(sm.var.target) $(sm.var.intermediates) $(sm.var.loadlibs)
endef #sm.tool.gcc.command.link.c++

define sm.tool.gcc.command.link.go
gccgo $(sm.var.flags) -o $(sm.var.target) $(sm.var.intermediates) $(sm.var.loadlibs)
endef #sm.tool.gcc.command.link.go

define sm.tool.gcc.command.link.asm
gcc $(sm.var.flags) -o $(sm.var.target) $(sm.var.intermediates) $(sm.var.loadlibs)
endef #sm.tool.gcc.command.link.asm

##
##
define sm.tool.gcc.command.archive
ar crs $(sm.var.target) $(sm.var.intermediates)
endef #sm.tool.gcc.command.archive

##
##
define sm.tool.gcc.config-module
$(call sm-check-not-empty, \
    sm.os.name \
    sm.config.variant \
 )\
$(eval \
   sm.this.gen_deps := true
   sm.this.type := $(firstword $(sm.this.toolset.args))
   sm.this.suffix := $$(sm.tool.gcc.suffix.target.$$(sm.this.type).$(sm.os.name))
   sm.this.compile.flags := $(sm.tool.gcc.flags.compile.variant.$(sm.config.variant))
   sm.this.compile.flags += $(sm.tool.gcc.flags.compile.os.$(sm.os.name))
   sm.this.link.flags := $(sm.tool.gcc.flags.link.variant.$(sm.config.variant))
   sm.this.link.flags += $(sm.tool.gcc.flags.link.os.$(sm.os.name))
 )
endef #sm.tool.gcc.config-module

sm.tool.gcc.transform.headers := h
sm.tool.gcc.transform.static  := bin
sm.tool.gcc.transform.shared  := bin
sm.tool.gcc.transform.exe     := bin

## sm.var.source
## sm.var.source.computed
## sm.var.source.lang
## sm.var.source.suffix
## sm.var.intermediate (source -> intermediate)
define sm.tool.gcc.transform-single-source
$(foreach _, $($(sm._this).toolset.args), \
  $(call sm.tool.gcc.transform-source-$(sm.tool.gcc.transform.$_)))
endef #sm.tool.gcc.transform-single-source

##
##
define sm.tool.gcc.transform-source-h
$(info TODO: gcc: header: $(sm.var.source.computed))
endef #sm.tool.gcc.transform-source-h

##
##
define sm.tool.gcc.transform-source-bin
$(call sm-check-not-empty, \
    sm._this $(sm._this).name \
    sm.var.source \
    sm.var.source.computed \
    sm.var.source.lang \
    sm.var.source.suffix \
    sm.var.intermediate \
 )\
$(eval #
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

  sm.var.flags.file := $$(call sm.fun.shift-flags-to-file, sm.var.flags, compile.$(sm.var.source.lang), $($(sm._this).compile.flags.infile))
  ifdef sm.var.flags.file
    $(sm.var.intermediate) : $$(sm.var.flags.file)
    sm.var.flags := @$$(sm.var.flags.file)
  endif

  sm.var.flags += $(strip $($(sm._this).compile.flags-$(sm.var.source)))

  $$(call sm-remove-duplicates,sm.var.flags)

  sm.var.command := $$(sm.tool.gcc.command.compile.$(sm.var.source.lang))
 )\
$(eval #
  $(sm._this).intermediates += $(sm.var.intermediate)
  $(sm.var.intermediate) : $(sm.var.source.computed)
	@[[ -d $$(@D) ]] || mkdir -p $$(@D)
	$(call sm.fun.wrap-rule-commands, gcc: $(sm.var.source.lang), $(sm.var.command))
 )
endef #sm.tool.gcc.transform-source-bin

##
##
define sm.tool.gcc.transform-intermediates
$(foreach _, $($(sm._this).toolset.args), \
  $(call sm.tool.gcc.transform-intermediates-$(sm.tool.gcc.transform.$_)))
endef #sm.tool.gcc.transform-intermediates

##
##
define sm.tool.gcc.transform-intermediates-h
$(info TODO: gcc: header: $(sm.var.source.computed))
endef #sm.tool.gcc.transform-intermediates-h

##
##
define sm.tool.gcc.transform-intermediates-bin
$(call sm-check-not-empty, sm._this \
  $(sm._this).name \
  $(sm._this).lang \
  $(sm._this).type \
  $(sm._this).intermediates \
 , gcc: unknown language)\
$(eval #
  sm.var.intermediates := $($(sm._this).intermediates)
  sm.var.target :=
  sm.var.flags :=
  ifeq ($($(sm._this).type),static)
    sm.var.target := $(patsubst $(sm.top)/%,%,$(sm.out.lib))/lib$($(sm._this).name)$($(sm._this).suffix)
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
    ifeq ($($(sm._this).type),shared)
      sm.var.flags := -shared $$(filter-out -shared,$$(sm.var.flags))
    endif
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
  sm.var.flags.file := $$(call sm.fun.shift-flags-to-file, sm.var.flags, link, $($(sm._this).link.flags.infile))
  ifdef sm.var.flags.file
    $(sm.var.intermediate) : $$(sm.var.flags.file)
    sm.var.flags := @$$(sm.var.flags.file)
  endif

  sm.var.flags.file := $$(call sm.fun.shift-flags-to-file, sm.var.intermediates, intermediates.link, $($(sm._this).link.intermediates.infile))
  ifdef sm.var.flags.file
    $(sm.var.intermediate) : $$(sm.var.flags.file)
    sm.var.intermediates.preq := $(sm.var.intermediates)
    sm.var.intermediates := @$$(sm.var.flags.file)
  else
    sm.var.intermediates.preq = $(sm.var.intermediates)
  endif

  sm.var.flags.file := $$(call sm.fun.shift-flags-to-file, sm.var.loadlibs, libs.link, $($(sm._this).libs.infile))
  ifdef sm.var.flags.file
    $(sm.var.intermediate) : $$(sm.var.flags.file)
    sm.var.loadlibs := @$$(sm.var.flags.file)
  endif

  ifeq ($($(sm._this).type),static)
    sm.var.command := $(sm.tool.gcc.command.archive)
  else
    sm.var.command := $(sm.tool.gcc.command.link.$($(sm._this).lang))
  endif
 )\
$(eval #
  $(sm._this).targets += $$(sm.var.target)
  $(sm.var.target) : $(sm.var.intermediates.preq)
	@[[ -d $$(@D) ]] || mkdir -p $$(@D)
	$(call sm.fun.wrap-rule-commands, gcc, $(sm.var.command))
  ifeq ($($(sm._this).type),shared)
    $$(info TODO: gcc: linkable target)
  endif
 )
endef #sm.tool.gcc.transform-intermediates-bin
