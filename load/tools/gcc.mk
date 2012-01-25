# -*- mode: Makefile:gnu -*-
#	Copyright(c) 2009, 2010, 2011, 2012, by Zhan Xin-ming <code@duzy.info>
#	

##
##  sm.tool.gcc
##

## a toolset can only be included only once
$(call sm.fun.new-toolset, gcc,\
    c++: .o: .cpp .c++ .cc .CC .C\
    go:  .o: .go\
    c:   .o: .c\
    asm: .o: .s .S\
 )

# $(info sm.tool.gcc.suffix.c: $(sm.tool.gcc.suffix.c))
# $(info sm.tool.gcc.suffix.c++: $(sm.tool.gcc.suffix.c++))
# $(info sm.tool.gcc.suffix.go: $(sm.tool.gcc.suffix.go))
# $(info sm.tool.gcc.suffix.asm: $(sm.tool.gcc.suffix.asm))
# $(info sm.tool.gcc.lang..c: $(sm.tool.gcc.lang..c))
# $(info sm.tool.gcc.lang..cpp: $(sm.tool.gcc.lang..cpp))
# $(info sm.tool.gcc.lang..go: $(sm.tool.gcc.lang..go))
# $(info sm.tool.gcc.lang..S: $(sm.tool.gcc.lang..S))
# $(info sm.tool.gcc.suffix.intermediate.c: $(sm.tool.gcc.suffix.intermediate.c))
# $(info sm.tool.gcc.suffix.intermediate.c++: $(sm.tool.gcc.suffix.intermediate.c++))
# $(info sm.tool.gcc.suffix.intermediate.go: $(sm.tool.gcc.suffix.intermediate.go))
# $(info sm.tool.gcc.suffix.intermediate.asm: $(sm.tool.gcc.suffix.intermediate.asm))

## Target link output file suffix.
sm.tool.gcc.suffix.target.win32.static := .a
sm.tool.gcc.suffix.target.win32.shared := .so
sm.tool.gcc.suffix.target.win32.exe := .exe
sm.tool.gcc.suffix.target.win32.t := .test.exe
sm.tool.gcc.suffix.target.linux.static := .a
sm.tool.gcc.suffix.target.linux.shared := .so
sm.tool.gcc.suffix.target.linux.exe :=
sm.tool.gcc.suffix.target.linux.t := .test

sm.tool.gcc.flags.compile.variant.debug := -g -ggdb
sm.tool.gcc.flags.compile.variant.release := -O3
sm.tool.gcc.flags.link.variant.debug := -g -ggdb
sm.tool.gcc.flags.link.variant.release := -O3 -Wl,-flto

sm.tool.gcc.flags.compile.os.linux :=
sm.tool.gcc.flags.compile.os.win32 := -mwindows
sm.tool.gcc.flags.link.os.linux :=
sm.tool.gcc.flags.link.os.win32 := -mwindows \
  -Wl,--enable-runtime-pseudo-reloc \
  -Wl,--enable-auto-import \

sm.tool.gcc.flags.compile.type.shared := -fPIC
sm.tool.gcc.flags.compile.type.static :=
sm.tool.gcc.flags.compile.type.exe :=
sm.tool.gcc.flags.link.type.shared := -Wl,--no-undefined
sm.tool.gcc.flags.link.type.static :=
sm.tool.gcc.flags.link.type.exe :=

##
## Compile Commands
define sm.tool.gcc.command.compile.c
gcc $(sm.var.flags) -o $@ -c $(sm.var.source)
endef #sm.tool.gcc.command.compile.c

define sm.tool.gcc.command.compile.c.d
gcc -MM -MT $(@:%.d=%) $(sm.var.flags) $(sm.var.source) > $@
endef #sm.tool.gcc.command.compile.c.d

define sm.tool.gcc.command.compile.c++
g++ $(sm.var.flags) -o $@ -c $(sm.var.source)
endef #sm.tool.gcc.command.compile.c++

define sm.tool.gcc.command.compile.c++.d
g++ -MM -MT $(@:%.d=%) $(sm.var.flags) $(sm.var.source) > $@
endef #sm.tool.gcc.command.compile.c++.d

define sm.tool.gcc.command.compile.go
gccgo $(sm.var.flags) -o $@ -c $(sm.var.source)
endef #sm.tool.gcc.command.compile.go

define sm.tool.gcc.command.compile.go.d
gccgo -MM -MT $(@:%.d=%) $(sm.var.flags) $(sm.var.source) > $@
endef #sm.tool.gcc.command.compile.go.d

define sm.tool.gcc.command.compile.asm
gcc $(sm.var.flags) -o $@ -c $(sm.var.source)
endef #sm.tool.gcc.command.compile.asm

define sm.tool.gcc.compile
$(eval #
  ifndef sm.tool.gcc.lang.$(suffix $*)
    $$(error smart: "smart: gcc2: unknown source: $(suffix $*)")
  endif
  ifndef sm.tool.gcc.command.compile.$(sm.tool.gcc.lang.$(suffix $*))
    $$(error smart: "sm.tool.gcc.command.compilesm.tool.gcc.command.compile.$(sm.tool.gcc.lang.$(suffix $*))" undefined)
  endif
 )$(sm.tool.gcc.command.compile.$(sm.tool.gcc.lang.$(suffix $*)))
endef #sm.tool.gcc.compile

define sm.tool.gcc.compile.d
$(eval #
  ifndef sm.tool.gcc.lang.$(suffix $*)
    $$(error smart: "smart: gcc2: unknown source: $(suffix $*)")
  endif
 )$(sm.tool.gcc.command.compile.$(sm.tool.gcc.lang.$(suffix $*)).d)
endef #sm.tool.gcc.compile.d

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

define sm.tool.gcc.args.types
$(filter-out -%, $($(sm._this).toolset.args))
endef #sm.tool.gcc.args.types

##
##
define sm.tool.gcc.config-module
$(call sm-check-not-empty, \
    sm.os.name \
    sm.config.variant \
 ,,gcc2:)\
$(eval \
   sm.this.gen_deps := true
   sm.this.type := $(firstword $(sm.this.toolset.args))
   sm.this.suffix := $$(sm.tool.gcc.suffix.target.$(sm.os.name).$$(sm.this.type))
   sm.this.compile.flags := $(sm.tool.gcc.flags.compile.variant.$(sm.config.variant))
   sm.this.compile.flags += $(sm.tool.gcc.flags.compile.os.$(sm.os.name))
   sm.this.compile.flags += $$(sm.tool.gcc.flags.compile.type.$$(sm.this.type))
   sm.this.link.flags := $(sm.tool.gcc.flags.link.variant.$(sm.config.variant))
   sm.this.link.flags += $(sm.tool.gcc.flags.link.os.$(sm.os.name))
   sm.this.link.flags += $$(sm.tool.gcc.flags.link.type.$$(sm.this.type))
 )\
$(eval #
  $(sm.out.inter)/$(sm.this.name)/%.o:
	@[[ -d $$(@D) ]] || mkdir -p $$(@D)
	$$(or $$(sm.tool.gcc.compile),echo "error:0: No command for \"$$@\"" && false)

  $(sm.out.inter)/$(sm.this.name)/%.o.d:
	@[[ -d $$(@D) ]] || mkdir -p $$(@D)
	@[[ -f $$(sm.var.source) ]] &&\
	$$(or $$(sm.tool.gcc.compile.d),echo "smart:0:info: no command for \"$$@\"")\
	|| (echo "$(sm.this.makefile):0: \"$$(sm.var.source)\" absent" && rm -f $$@ && false)

  $(sm.out)/include/%.h:
	@( echo smart: header: $$@ ) &&\
	 ([[ -d $$(dir $$@) ]] || mkdir -p $$(dir $$@)) &&\
	 (cp -u $$< $$@)
 )
endef #sm.tool.gcc.config-module

sm.tool.gcc.transform.headers := h
sm.tool.gcc.transform.static  := c
sm.tool.gcc.transform.shared  := c
sm.tool.gcc.transform.exe     := c

## sm.var.source
## sm.var.source.lang
## sm.var.source.suffix
define sm.tool.gcc.transform-single-source
$(foreach _, $(sm.tool.gcc.args.types), \
  $(call sm.tool.gcc.transform-source-$(sm.tool.gcc.transform.$_)))
endef #sm.tool.gcc.transform-single-source

##
##
define sm.tool.gcc.transform-source-h
$(eval #
  ifeq ($(sm.var.source.suffix),.h)
    $$(info TODO: header: $(sm.var.source))
  endif
 )
endef #sm.tool.gcc.transform-source-h

##
## transform .c or .cpp source
define sm.tool.gcc.transform-source-c
$(call sm-check-not-empty, \
    sm._this $(sm._this).name \
    sm.var.source \
    sm.var.source.lang \
    sm.var.source.suffix \
 )\
$(eval #
  sm.var.flags :=
  ifdef sm.var.specific_flags
    sm.var.flags := $(sm.var.specific_flags)
  else
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
  endif

  $$(call sm-remove-duplicates,sm.var.flags)

  sm.temp._flagsfile := $$(call sm.fun.shift-flags-to-file, sm.var.flags, compile.$(sm.var.source.lang), $($(sm._this).compile.flags.infile))
  ifdef sm.temp._flagsfile
    sm.var.flags := @$$(sm.temp._flagsfile)
  endif

  sm.var.flags += $(strip $($(sm._this).compile.flags-$(sm.var.source)))

  $$(call sm-remove-duplicates,sm.var.flags)

  sm.var.prefix := $($(sm._this).prefix:%/=%)
  sm.var.intermediate := $($(sm._this).out.inter)/$(sm.var.source).o
  ifndef sm.var.prefix
    $$(error no module prefix: "$($(sm._this).prefix)")
  endif
 )\
$(eval #
  $(sm._this).intermediates += $(sm.var.intermediate)

  ## Draw the dependency on the source to make it complain if the source
  ## is absent:
  $(sm.var.intermediate): sm.var.flags := $(sm.var.flags)
  $(sm.var.intermediate): sm.var.source := $(sm.var.prefix)/$(sm.var.source)
  $(sm.var.intermediate): $(sm.temp._flagsfile) $(sm.var.prefix)/$(sm.var.source)

  ifeq ($(call sm-true,$($(sm._this).gen_deps)),true)
    -include $(sm.var.intermediate).d
    $(sm.var.intermediate).d: sm.var.flags := $(sm.var.flags)
    $(sm.var.intermediate).d: sm.var.source := $(sm.var.prefix)/$(sm.var.source)
    $(sm.var.intermediate).d: $(sm.temp._flagsfile) $(sm.var.prefix)/$(sm.var.source)
  endif
 )
endef #sm.tool.gcc.transform-source-c

##
##
define sm.tool.gcc.transform-intermediates
$(foreach _, $(sm.tool.gcc.args.types), \
  $(call sm.tool.gcc.transform-intermediates-$(sm.tool.gcc.transform.$_)))
endef #sm.tool.gcc.transform-intermediates

##
##
define sm.tool.gcc.transform-intermediates-h
$(foreach _, $(filter $(sm._this).headers%,$(.VARIABLES)),\
  $(eval #
    sm.temp._prefix := $(_:$(sm._this).headers%=%)
    sm.temp._prefix := $$(sm.temp._prefix:.%=%)
    ifdef sm.temp._prefix
      sm.temp._prefix := $$(sm.temp._prefix)/
    endif
   )\
  $(foreach h, $($_), $(eval #
    sm.temp._pubheader := $(sm.out)/include/$(sm.temp._prefix)$h
    sm.var.source := $h
    $$(sm.temp._pubheader): $$(call sm.fun.compute-source-of-local)
    headers-$($(sm._this).name): $$(sm.temp._pubheader)
   ))\
 )\
$(eval #
  .PHONY: headers-$($(sm._this).name)
  $(sm._this).targets += headers-$($(sm._this).name)
 )
endef #sm.tool.gcc.transform-intermediates-h

##
## .c or .cpp intermediates
define sm.tool.gcc.transform-intermediates-c
$(call sm-check-not-empty, sm._this \
  $(sm._this).name \
  $(sm._this).lang \
  $(sm._this).type \
  $(sm._this).intermediates \
 ,,gcc2:)\
$(eval #
  sm.var.intermediates := $($(sm._this).intermediates)
  sm.var.target :=
  sm.var.target.link :=
  sm.var.flags :=
  ifeq ($($(sm._this).type),static)
    sm.var.target := $(patsubst $(sm.top)/%,%,$(sm.out.lib))/lib$($(sm._this).name:lib%=%)$($(sm._this).suffix)
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
      sm.var.target.link := $(patsubst $(sm.top)/%,%,$(sm.out.lib))/lib$($(sm._this).name:lib%=%)$($(sm._this).suffix)
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
    sm.var.command := $(sm.tool.gcc.command.archive)
  else
    sm.var.command := $(sm.tool.gcc.command.link.$($(sm._this).lang))
  endif
 )\
$(eval #
  $(sm._this).targets += $(sm.var.target)
  $(sm.var.target) : $(sm.var.intermediates.preq)
	@[[ -d $$(@D) ]] || mkdir -p $$(@D)
	$(call sm.fun.wrap-rule-commands, gcc2, $(sm.var.command))

  ifdef sm.var.target.link
    $(sm._this).targets += $(sm.var.target.link)
    $(sm.var.target.link) : $(sm.var.target)
	@[[ -d $$(@D) ]] || mkdir -p $$(@D)
	$(call sm.fun.wrap-rule-commands, gcc2, ln -sf $(sm.top)/$(sm.var.target) $(sm.var.target.link))
  endif
 )\
$(eval #
  ifdef $(sm._this).install_dir
    $$(sm.tool.gcc.install-target)
  endif
 )
endef #sm.tool.gcc.transform-intermediates-c

sm.tool.gcc.install_prefix.exe := bin
sm.tool.gcc.install_prefix.static := lib
sm.tool.gcc.install_prefix.shared := bin
define sm.tool.gcc.install_target
$($(sm._this).install_dir)/$(strip \
  $(or $(sm.tool.gcc.install_prefix.$($(sm._this).type)))\
 )/$($(sm._this).name)$($(sm._this).suffix)
endef #sm.tool.gcc.install_target

##
define sm.tool.gcc.install-target
$(eval \
  $(sm._this).installs += install-$($(sm._this).type)-$($(sm._this).name)
  sm.temp._install_target := $(sm.tool.gcc.install_target)
 )\
$(eval \
  install-$($(sm._this).type)-$($(sm._this).name): $(sm.temp._install_target)
  $(sm.temp._install_target): $(sm.var.target)
	@[[ -d $$(@D) ]] || mkdir -p $$(@D) && cp -f $$< $$@ && echo "smart: installed $$@"
 )
endef #sm.tool.gcc.install-target
