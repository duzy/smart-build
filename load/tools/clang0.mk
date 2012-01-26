# -*- mode: Makefile:gnu -*-
#	Copyright(c) 2009, 2010, 2011, 2012, by Zhan Xin-ming <code@duzy.info>
#	

##
##  sm.tool.clang0
##

## make sure that gcc.mk is included only once
$(call sm-check-origin, sm.tool.clang0, undefined)

sm.tool.clang0 := true

## Languages supported by this toolset, the order is significant,
## the order defines the priority of linker
sm.tool.clang0.langs := c++ c asm ll
sm.tool.clang0.suffix.c := .c
sm.tool.clang0.suffix.c++ := .cpp .c++ .cc .CC .C
sm.tool.clang0.suffix.asm := .s .S
sm.tool.clang0.suffix.ll := .ll

## Compilation output files(objects) suffixes.
sm.tool.clang0.suffix.intermediate.c := .o
sm.tool.clang0.suffix.intermediate.c++ := .o
sm.tool.clang0.suffix.intermediate.asm := .o
sm.tool.clang0.suffix.intermediate.ll := .o

## Target link output file suffix.
sm.tool.clang0.suffix.target.win32.static := .a
sm.tool.clang0.suffix.target.win32.shared := .so
sm.tool.clang0.suffix.target.win32.exe := .exe
sm.tool.clang0.suffix.target.win32.t := .test.exe
sm.tool.clang0.suffix.target.linux.static := .a
sm.tool.clang0.suffix.target.linux.shared := .so
sm.tool.clang0.suffix.target.linux.exe :=
sm.tool.clang0.suffix.target.linux.t := .test

sm.tool.clang0.flags.compile.variant.debug := -g -ggdb
sm.tool.clang0.flags.compile.variant.release := -O3
sm.tool.clang0.flags.link.variant.debug := -g -ggdb
sm.tool.clang0.flags.link.variant.release := -O3 -Wl,-flto

sm.tool.clang0.flags.compile.os.linux :=
sm.tool.clang0.flags.compile.os.win32 := -mwindows
sm.tool.clang0.flags.link.os.linux :=
sm.tool.clang0.flags.link.os.win32 := -mwindows \
  -Wl,--enable-runtime-pseudo-reloc \
  -Wl,--enable-auto-import \

sm.tool.clang0.flags.compile.type.shared :=
sm.tool.clang0.flags.compile.type.static :=
sm.tool.clang0.flags.compile.type.exe :=
sm.tool.clang0.flags.link.type.shared := -Wl,--no-undefined
sm.tool.clang0.flags.link.type.static :=
sm.tool.clang0.flags.link.type.exe :=

##
## Compile Commands
define sm.tool.clang0.command.compile.c
clang $(sm.var.flags) -o $(sm.var.intermediate) -c $(sm.var.source.computed)
endef #sm.tool.clang0.command.compile.c

define sm.tool.clang0.command.compile.c.d
clang -MM -MT $(sm.var.intermediate) $(sm.var.flags) $(sm.var.source.computed) > $(sm.var.intermediate).d
endef #sm.tool.clang0.command.compile.c.d

define sm.tool.clang0.command.compile.c++
clang++ $(sm.var.flags) -o $(sm.var.intermediate) -c $(sm.var.source.computed)
endef #sm.tool.clang0.command.compile.c++

define sm.tool.clang0.command.compile.c++.d
clang++ -MM -MT $(sm.var.intermediate) $(sm.var.flags) $(sm.var.source.computed) > $(sm.var.intermediate).d
endef #sm.tool.clang0.command.compile.c++.d

define sm.tool.clang0.command.compile.asm
clang $(sm.var.flags) -o $(sm.var.intermediate) -c $(sm.var.source.computed)
endef #sm.tool.clang0.command.compile.asm

define sm.tool.clang0.command.compile.ll
llvmc $(sm.var.flags) -o $(sm.var.intermediate) -c $(sm.var.source.computed)
endef #sm.tool.clang0.command.compile.ll

##
##
define sm.tool.clang0.command.link.c
clang $(sm.var.flags) -o $(sm.var.target) $(sm.var.intermediates) $(sm.var.loadlibs)
endef #sm.tool.clang0.command.link.c

define sm.tool.clang0.command.link.c++
clang++ $(sm.var.flags) -o $(sm.var.target) $(sm.var.intermediates) $(sm.var.loadlibs)
endef #sm.tool.clang0.command.link.c++

define sm.tool.clang0.command.link.asm
clang $(sm.var.flags) -o $(sm.var.target) $(sm.var.intermediates) $(sm.var.loadlibs)
endef #sm.tool.clang0.command.link.asm

##
##
define sm.tool.clang0.command.archive
ar crs $(sm.var.target) $(sm.var.intermediates)
endef #sm.tool.clang0.command.archive

define sm.tool.clang0.args.types
$(filter-out -%, $($(sm._this).toolset.args))
endef #sm.tool.clang0.args.types

##
##
define sm.tool.clang0.config-module
$(call sm-check-not-empty, \
    sm.os.name \
    sm.config.variant \
 )\
$(eval \
   sm.this.gen_deps := true
   sm.this.type := $(firstword $(sm.this.toolset.args))
   sm.this.suffix := $$(sm.tool.clang0.suffix.target.$(sm.os.name).$$(sm.this.type))
   sm.this.compile.flags := $(sm.tool.clang0.flags.compile.variant.$(sm.config.variant))
   sm.this.compile.flags += $(sm.tool.clang0.flags.compile.os.$(sm.os.name))
   sm.this.compile.flags += $$(sm.tool.clang0.flags.compile.type.$$(sm.this.type))
   sm.this.link.flags := $(sm.tool.clang0.flags.link.variant.$(sm.config.variant))
   sm.this.link.flags += $(sm.tool.clang0.flags.link.os.$(sm.os.name))
   sm.this.link.flags += $$(sm.tool.clang0.flags.link.type.$$(sm.this.type))
 )
endef #sm.tool.clang0.config-module

sm.tool.clang0.transform.headers := h
sm.tool.clang0.transform.static  := bin
sm.tool.clang0.transform.shared  := bin
sm.tool.clang0.transform.exe     := bin

## sm.var.source
## sm.var.source.computed
## sm.var.source.lang
## sm.var.source.suffix
## sm.var.intermediate (source -> intermediate)
define sm.tool.clang0.transform-single-source
$(foreach _, $(sm.tool.clang0.args.types), \
  $(call sm.tool.clang0.transform-source-$(sm.tool.clang0.transform.$_)))
endef #sm.tool.clang0.transform-single-source

##
##
define sm.tool.clang0.transform-source-h
$(info TODO: gcc: header: $(sm.var.source.computed))
endef #sm.tool.clang0.transform-source-h

##
##
define sm.tool.clang0.transform-source-bin
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

  sm.temp._flagsfile := $$(call sm.fun.shift-flags-to-file, sm.var.flags, compile.$(sm.var.source.lang), $($(sm._this).compile.flags.infile))
  ifdef sm.temp._flagsfile
    $(sm.var.intermediate) $(sm.var.intermediate).d : $$(sm.temp._flagsfile)
    sm.var.flags := @$$(sm.temp._flagsfile)
  endif

  sm.var.flags += $(strip $($(sm._this).compile.flags-$(sm.var.source)))

  $$(call sm-remove-duplicates,sm.var.flags)

  sm.var.command := $$(sm.tool.clang0.command.compile.$(sm.var.source.lang))
  sm.var.command.d := $$(sm.tool.clang0.command.compile.$(sm.var.source.lang).d)
 )\
$(eval #
  $(sm._this).intermediates += $(sm.var.intermediate)
  $(sm.var.intermediate) : $(sm.var.source.computed)
	@[[ -d $$(@D) ]] || mkdir -p $$(@D)
	$(call sm.fun.wrap-rule-commands, gcc: $(sm.var.source.lang), $(sm.var.command))

  ifdef sm.var.command.d
  ifeq ($(call sm-true,$($(sm._this).gen_deps)),true)
    -include $(sm.var.intermediate).d
    $(sm.var.intermediate).d : $(sm.var.source.computed)
	@[[ -d $$(@D) ]] || mkdir -p $$(@D)
	$(call sm.fun.wrap-rule-commands, gcc: $(sm.var.source.lang), $(sm.var.command.d))
  endif
  endif
 )
endef #sm.tool.clang0.transform-source-bin

##
##
define sm.tool.clang0.transform-intermediates
$(foreach _, $(sm.tool.clang0.args.types), \
  $(call sm.tool.clang0.transform-intermediates-$(sm.tool.clang0.transform.$_)))
endef #sm.tool.clang0.transform-intermediates

##
##
define sm.tool.clang0.transform-intermediates-h
$(eval #
  sm.temp._headervars := $(filter $(sm._this).headers%,$(.VARIABLES))
  sm.temp._pubheaders :=
 )\
$(foreach _, $(sm.temp._headervars),\
  $(eval #
    sm.temp._pubprefix := $(_:$(sm._this).headers%=%)
    sm.temp._pubprefix := $$(sm.temp._pubprefix:.%=%)
    ifdef sm.temp._pubprefix
      sm.temp._pubprefix := $$(sm.temp._pubprefix)/
    endif
   )\
  $(foreach _h, $($_),\
    $(eval sm.var.source := $(_h))\
    $(eval #
      sm.temp._pubheader := $(sm.out)/include/$(sm.temp._pubprefix)$(_h)
      sm.temp._pubheaders += $$(sm.temp._pubheader)
      $$(sm.temp._pubheader) : $(call sm.fun.compute-source-of-local)
	@( echo smart: header: $$@ ) &&\
	 ([ -d $$(dir $$@) ] || mkdir -p $$(dir $$@)) && (cp -u $$< $$@)
     )\
   )\
 )\
$(eval #
  headers-$($(sm._this).name) : $(sm.temp._pubheaders)
  $(sm._this).targets += headers-$($(sm._this).name)
 )
endef #sm.tool.clang0.transform-intermediates-h

##
##
define sm.tool.clang0.transform-intermediates-bin
$(call sm-check-not-empty, sm._this \
  $(sm._this).name \
  $(sm._this).lang \
  $(sm._this).type \
  $(sm._this).intermediates \
 , gcc: unknown language)\
$(eval #
  sm.var.intermediates := $($(sm._this).intermediates)
  sm.var.target :=
  sm.var.target.link :=
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
      sm.var.target.link := $(patsubst $(sm.top)/%,%,$(sm.out.lib))/lib$($(sm._this).name)$($(sm._this).suffix)
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

  ifeq ($($(sm._this).type),static)
    sm.var.command := $(sm.tool.clang0.command.archive)
  else
    sm.var.command := $(sm.tool.clang0.command.link.$($(sm._this).lang))
  endif
 )\
$(eval #
  $(sm._this).targets += $(sm.var.target)
  $(sm.var.target) : $(sm.var.intermediates.preq)
	@[[ -d $$(@D) ]] || mkdir -p $$(@D)
	$(call sm.fun.wrap-rule-commands, gcc, $(sm.var.command))

  ifdef sm.var.target.link
    $(sm._this).targets += $(sm.var.target.link)
    $(sm.var.target.link) : $(sm.var.target)
	@[[ -d $$(@D) ]] || mkdir -p $$(@D)
	$(call sm.fun.wrap-rule-commands, gcc, ln -sf $(sm.top)/$(sm.var.target) $(sm.var.target.link))
  endif
 )
endef #sm.tool.clang0.transform-intermediates-bin
