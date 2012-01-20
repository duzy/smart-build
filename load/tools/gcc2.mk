# -*- mode: Makefile:gnu -*-
#	Copyright(c) 2009, 2010, 2011, 2012, by Zhan Xin-ming <code@duzy.info>
#	

##
##  sm.tool.gcc2
##

## a toolset can only be included only once
$(call sm.fun.new-toolset, gcc2,\
    c:   .o: .c\
    c++: .o: .cpp .c++ .cc .CC .C\
    go:  .o: .go\
    asm: .o: .s .S\
 )

# $(info sm.tool.gcc2.suffix.c: $(sm.tool.gcc2.suffix.c))
# $(info sm.tool.gcc2.suffix.c++: $(sm.tool.gcc2.suffix.c++))
# $(info sm.tool.gcc2.suffix.go: $(sm.tool.gcc2.suffix.go))
# $(info sm.tool.gcc2.suffix.asm: $(sm.tool.gcc2.suffix.asm))
# $(info sm.tool.gcc2.lang..c: $(sm.tool.gcc2.lang..c))
# $(info sm.tool.gcc2.lang..cpp: $(sm.tool.gcc2.lang..cpp))
# $(info sm.tool.gcc2.lang..go: $(sm.tool.gcc2.lang..go))
# $(info sm.tool.gcc2.lang..S: $(sm.tool.gcc2.lang..S))
# $(info sm.tool.gcc2.suffix.intermediate.c: $(sm.tool.gcc2.suffix.intermediate.c))
# $(info sm.tool.gcc2.suffix.intermediate.c++: $(sm.tool.gcc2.suffix.intermediate.c++))
# $(info sm.tool.gcc2.suffix.intermediate.go: $(sm.tool.gcc2.suffix.intermediate.go))
# $(info sm.tool.gcc2.suffix.intermediate.asm: $(sm.tool.gcc2.suffix.intermediate.asm))

## Target link output file suffix.
sm.tool.gcc2.suffix.target.win32.static := .a
sm.tool.gcc2.suffix.target.win32.shared := .so
sm.tool.gcc2.suffix.target.win32.exe := .exe
sm.tool.gcc2.suffix.target.win32.t := .test.exe
sm.tool.gcc2.suffix.target.linux.static := .a
sm.tool.gcc2.suffix.target.linux.shared := .so
sm.tool.gcc2.suffix.target.linux.exe :=
sm.tool.gcc2.suffix.target.linux.t := .test

sm.tool.gcc2.flags.compile.variant.debug := -g -ggdb
sm.tool.gcc2.flags.compile.variant.release := -O3
sm.tool.gcc2.flags.link.variant.debug := -g -ggdb
sm.tool.gcc2.flags.link.variant.release := -O3 -Wl,-flto

sm.tool.gcc2.flags.compile.os.linux :=
sm.tool.gcc2.flags.compile.os.win32 := -mwindows
sm.tool.gcc2.flags.link.os.linux :=
sm.tool.gcc2.flags.link.os.win32 := -mwindows \
  -Wl,--enable-runtime-pseudo-reloc \
  -Wl,--enable-auto-import \

sm.tool.gcc2.flags.compile.type.shared := -fPIC
sm.tool.gcc2.flags.compile.type.static :=
sm.tool.gcc2.flags.compile.type.exe :=
sm.tool.gcc2.flags.link.type.shared := -Wl,--no-undefined
sm.tool.gcc2.flags.link.type.static :=
sm.tool.gcc2.flags.link.type.exe :=

##
## Compile Commands
define sm.tool.gcc2.command.compile.c
gcc $(sm.var.flags) -o $@ -c $(sm.var.source)
endef #sm.tool.gcc2.command.compile.c

define sm.tool.gcc2.command.compile.c.d
gcc -MM -MT $(@:%.d=%) $(sm.var.flags) $(sm.var.source) > $@
endef #sm.tool.gcc2.command.compile.c.d

define sm.tool.gcc2.command.compile.c++
g++ $(sm.var.flags) -o $@ -c $(sm.var.source)
endef #sm.tool.gcc2.command.compile.c++

define sm.tool.gcc2.command.compile.c++.d
g++ -MM -MT $(@:%.d=%) $(sm.var.flags) $(sm.var.source) > $@
endef #sm.tool.gcc2.command.compile.c++.d

define sm.tool.gcc2.command.compile.go
gccgo $(sm.var.flags) -o $@ -c $(sm.var.source)
endef #sm.tool.gcc2.command.compile.go

define sm.tool.gcc2.command.compile.go.d
gccgo -MM -MT $(@:%.d=%) $(sm.var.flags) $(sm.var.source) > $@
endef #sm.tool.gcc2.command.compile.go.d

define sm.tool.gcc2.command.compile.asm
gcc $(sm.var.flags) -o $@ -c $(sm.var.source)
endef #sm.tool.gcc2.command.compile.asm

define sm.tool.gcc2.compile
$(eval #
  ifndef sm.tool.gcc2.lang.$(suffix $*)
    $$(error smart: "smart: gcc2: unknown source: $(suffix $*)")
  endif
  ifndef sm.tool.gcc2.command.compile.$(sm.tool.gcc2.lang.$(suffix $*))
    $$(error smart: "sm.tool.gcc2.command.compilesm.tool.gcc2.command.compile.$(sm.tool.gcc2.lang.$(suffix $*))" undefined)
  endif
 )$(sm.tool.gcc2.command.compile.$(sm.tool.gcc2.lang.$(suffix $*)))
endef #sm.tool.gcc2.compile

define sm.tool.gcc2.compile.d
$(eval #
  ifndef sm.tool.gcc2.lang.$(suffix $*)
    $$(error smart: "smart: gcc2: unknown source: $(suffix $*)")
  endif
 )$(sm.tool.gcc2.command.compile.$(sm.tool.gcc2.lang.$(suffix $*)).d)
endef #sm.tool.gcc2.compile.d

##
##
define sm.tool.gcc2.command.link.c
gcc $(sm.var.flags) -o $(sm.var.target) $(sm.var.intermediates) $(sm.var.loadlibs)
endef #sm.tool.gcc2.command.link.c

define sm.tool.gcc2.command.link.c++
g++ $(sm.var.flags) -o $(sm.var.target) $(sm.var.intermediates) $(sm.var.loadlibs)
endef #sm.tool.gcc2.command.link.c++

define sm.tool.gcc2.command.link.go
gccgo $(sm.var.flags) -o $(sm.var.target) $(sm.var.intermediates) $(sm.var.loadlibs)
endef #sm.tool.gcc2.command.link.go

define sm.tool.gcc2.command.link.asm
gcc $(sm.var.flags) -o $(sm.var.target) $(sm.var.intermediates) $(sm.var.loadlibs)
endef #sm.tool.gcc2.command.link.asm

##
##
define sm.tool.gcc2.command.archive
ar crs $(sm.var.target) $(sm.var.intermediates)
endef #sm.tool.gcc2.command.archive

define sm.tool.gcc2.args.types
$(filter-out -%, $($(sm._this).toolset.args))
endef #sm.tool.gcc2.args.types

##
##
define sm.tool.gcc2.config-module
$(call sm-check-not-empty, \
    sm.os.name \
    sm.config.variant \
 ,,gcc2:)\
$(eval \
   sm.this.gen_deps := true
   sm.this.type := $(firstword $(sm.this.toolset.args))
   sm.this.suffix := $$(sm.tool.gcc2.suffix.target.$(sm.os.name).$$(sm.this.type))
   sm.this.compile.flags := $(sm.tool.gcc2.flags.compile.variant.$(sm.config.variant))
   sm.this.compile.flags += $(sm.tool.gcc2.flags.compile.os.$(sm.os.name))
   sm.this.compile.flags += $$(sm.tool.gcc2.flags.compile.type.$$(sm.this.type))
   sm.this.link.flags := $(sm.tool.gcc2.flags.link.variant.$(sm.config.variant))
   sm.this.link.flags += $(sm.tool.gcc2.flags.link.os.$(sm.os.name))
   sm.this.link.flags += $$(sm.tool.gcc2.flags.link.type.$$(sm.this.type))
 )\
$(eval #
  #$(sm.out.inter)/$(sm.this.name)/%.o: $(sm.this.prefix)/%
  $(sm.out.inter)/$(sm.this.name)/%.o:
	@[[ -d $$(@D) ]] || mkdir -p $$(@D)
	$$(sm.tool.gcc2.compile)

  #$(sm.out.inter)/$(sm.this.name)/%.c.o.d: $(sm.this.prefix)/%.c
  $(sm.out.inter)/$(sm.this.name)/%.o.d:
	@[[ -d $$(@D) ]] || mkdir -p $$(@D)
	$$(sm.tool.gcc2.compile.d)
 )
endef #sm.tool.gcc2.config-module

sm.tool.gcc2.transform.headers := h
sm.tool.gcc2.transform.static  := c
sm.tool.gcc2.transform.shared  := c
sm.tool.gcc2.transform.exe     := c

## sm.var.source
## sm.var.source.computed
## sm.var.source.lang
## sm.var.source.suffix
## sm.var.intermediate (source -> intermediate)
define sm.tool.gcc2.transform-single-source
$(foreach _, $(sm.tool.gcc2.args.types), \
  $(call sm.tool.gcc2.transform-source-$(sm.tool.gcc2.transform.$_)))
endef #sm.tool.gcc2.transform-single-source

##
##
define sm.tool.gcc2.transform-source-h
$(info TODO: gcc2: header: $(sm.var.source.computed))
endef #sm.tool.gcc2.transform-source-h

##
## transform .c or .cpp source
define sm.tool.gcc2.transform-source-c
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
    $(sm.var.intermediate) $(sm.var.intermediate).d : $$(sm.temp._flagsfile)
    sm.var.flags := @$$(sm.temp._flagsfile)
  endif

  sm.var.flags += $(strip $($(sm._this).compile.flags-$(sm.var.source)))

  $$(call sm-remove-duplicates,sm.var.flags)

  sm.var.command := $$(sm.tool.gcc2.command.compile.$(sm.var.source.lang))
  sm.var.command.d := $$(sm.tool.gcc2.command.compile.$(sm.var.source.lang).d)
 )\
$(eval #
  $(sm._this).intermediates += $($(sm._this).out.inter)/$(sm.var.source).o

  $($(sm._this).out.inter)/$(sm.var.source).o: sm.var.source := $(sm.this.prefix)/$(sm.var.source)
  $($(sm._this).out.inter)/$(sm.var.source).o: sm.var.flags := $(sm.var.flags)

  ifdef sm.var.command.d
  ifeq ($(call sm-true,$($(sm._this).gen_deps)),true)
    -include $($(sm._this).out.inter)/$(sm.var.source).o.d
    $($(sm._this).out.inter)/$(sm.var.source).o.d: sm.var.source := $(sm.this.prefix)/$(sm.var.source)
    $($(sm._this).out.inter)/$(sm.var.source).o.d: sm.var.flags := $(sm.var.flags)
  endif
  endif
 )
endef #sm.tool.gcc2.transform-source-c

##
##
define sm.tool.gcc2.transform-intermediates
$(foreach _, $(sm.tool.gcc2.args.types), \
  $(call sm.tool.gcc2.transform-intermediates-$(sm.tool.gcc2.transform.$_)))
endef #sm.tool.gcc2.transform-intermediates

##
##
define sm.tool.gcc2.transform-intermediates-h
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
endef #sm.tool.gcc2.transform-intermediates-h

##
## .c or .cpp intermediates
define sm.tool.gcc2.transform-intermediates-c
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
    sm.var.command := $(sm.tool.gcc2.command.archive)
  else
    sm.var.command := $(sm.tool.gcc2.command.link.$($(sm._this).lang))
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
    $$(sm.tool.gcc2.install-target)
  endif
 )
endef #sm.tool.gcc2.transform-intermediates-c

sm.tool.gcc2.install_prefix.exe := bin
sm.tool.gcc2.install_prefix.static := lib
sm.tool.gcc2.install_prefix.shared := bin
define sm.tool.gcc2.install_target
$($(sm._this).install_dir)/$(strip \
  $(or $(sm.tool.gcc2.install_prefix.$($(sm._this).type)))\
 )/$($(sm._this).name)$($(sm._this).suffix)
endef #sm.tool.gcc2.install_target

##
define sm.tool.gcc2.install-target
$(eval \
  $(sm._this).installs += install-$($(sm._this).type)-$($(sm._this).name)
  sm.temp._install_target := $(sm.tool.gcc2.install_target)
 )\
$(eval \
  install-$($(sm._this).type)-$($(sm._this).name): $(sm.temp._install_target)
  $(sm.temp._install_target): $(sm.var.target)
	@[[ -d $$(@D) ]] || mkdir -p $$(@D) && cp -f $$< $$@ && echo "smart: installed $$@"
 )
endef #sm.tool.gcc2.install-target
