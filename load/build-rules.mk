#
#  For any source list of mixture suffixes, e.g. 'foo.cpp foo.S foo.w',
#  I will first check sm.tool.$(sm.this.toolset) to see if the toolset
#  can process the source files, if not I will check sm.tool.common for
#  the source files, if sm.tool.common can't handle it, I will complain
#  with a error.
#
#  The source files with suffix '.t' are special fot unit test projects.
#  They are special because event if no toolset will handle with them, 
#  wouldn't it be treated as strange. And processing the .t source files
#  requires sm.this.lang to be specified.
#  

ifeq ($(sm._this),)
  $(error smart: internal: sm._this is empty)
endif # sm._this == ""

## check module name
ifeq ($($(sm._this).name),)
  $(error smart: internal: $(sm._this).name is empty)
endif # $(sm._this).name == ""

##################################################

## configure the module if not yet done
$(sm._this)._configured := true

sm.var.depend.suffixes.static := .d
sm.var.depend.suffixes.shared := .d
sm.var.depend.suffixes.exe := .d
sm.var.depend.suffixes.t := .d
$(sm._this).depend.suffixes := $(sm.var.depend.suffixes.$($(sm._this).type))
$(sm._this).out.tmp := $(sm.out.tmp)/$($(sm._this).name)
$(sm._this).user_defined_targets := $($(sm._this).targets)
$(sm._this).targets :=

sm.var.temp._ := $($(sm._this).dir:$(sm.top)%=%)
sm.var.temp._ := $(sm.var.temp._:%.=%)
sm.var.temp._ := $(sm.var.temp._:/%=%)
sm.var.temp._ := ${if $(sm.var.temp._),$(sm.var.temp._)/}
$(sm._this)._intermediate_prefix := $(sm.var.temp._)

##
define sm.fun.compute-sources-by-lang
  ${eval \
  sm.var.temp._suffix_pat.$(sm.var.temp._lang)  := $($(sm.var.toolset).suffix.$(sm.var.temp._lang):%=\%%)
  $(sm._this).sources.$(sm.var.temp._lang)          := $$(filter $$(sm.var.temp._suffix_pat.$(sm.var.temp._lang)),$($(sm._this).sources))
  $(sm._this).sources.external.$(sm.var.temp._lang) := $$(filter $$(sm.var.temp._suffix_pat.$(sm.var.temp._lang)),$($(sm._this).sources.external))
  $(sm._this).sources.has.$(sm.var.temp._lang)      := $$(if $$($(sm._this).sources.$(sm.var.temp._lang))$$($(sm._this).sources.external.$(sm.var.temp._lang)),true)
  }
endef #sm.fun.compute-sources-by-lang

## Compute sources of each language supported by the toolset.
sm.var.toolset := sm.tool.$($(sm._this).toolset)
${foreach sm.var.temp._lang,$($(sm.var.toolset).langs),\
  $(sm.fun.compute-sources-by-lang)\
 }

#-----------------------------------------------
#-----------------------------------------------
ifneq ($($(sm._this).using_list),)
  #ifeq ($(flavor $(sm._this).using_list.computed),undefine)
  ## FIXME: it looks like a gmake bug:
  ##   if these variables is not initialized using ":=", those "+=" in cused.mk
  ##   will act like a ":=".
  $(sm._this).using_list.computed :=
  $(sm._this).used.defines        :=
  $(sm._this).used.includes       :=
  $(sm._this).used.compile.flags  :=
  $(sm._this).used.link.flags     :=
  $(sm._this).used.libdirs        :=
  $(sm._this).used.libs           :=
  #endif # $(sm._this).using_list.computed is undefine
  ${foreach sm.var.temp._use,$($(sm._this).using_list),\
    ${eval sm._that := sm.module.$(sm.var.temp._use)}\
    ${eval include $(sm.dir.buildsys)/cused.mk}\
   }
endif # $(sm._this).using_list != ""

ifneq ($($(sm._this).using),)
  ${warning "sm.this.using" is not working with GNU Make!}

  define sm.fun.using-module
    ${info smart: using $(sm.var.temp._modir)}\
    ${eval \
      ${if ${filter $(sm.var.temp._modir),$(sm.global.using.loaded)},,\
          sm.global.using.loaded += $(sm.var.temp._modir)
          sm.var.temp._using := ${wildcard $(sm.var.temp._modir)/smart.mk}
          sm.rules.phony.* += using-$$(sm.var.temp._using)
          goal-$($(sm._this).name) : using-$$(sm.var.temp._using)
          using-$$(sm.var.temp._using): ; \
            $$(info smart: using $$@)\
	    $$(call sm-load-module,$$(sm.var.temp._using))\
            echo using: $$@ -> $$(info $(sm.result.module.name))
       }
     }
  endef #sm.fun.using-module

  ${foreach sm.var.temp._modir,$($(sm._this).using),$(sm.fun.using-module)}
endif # $(sm._this).using != ""

##################################################

sm.var.action.static := archive
sm.var.action.shared := link
sm.var.action.exe := link
sm.var.action.t := link
sm.var.action := $(sm.var.action.$($(sm._this).type))

ifneq ($(strip $($(sm._this).type)),depends)
  sm.var.toolset := sm.tool.$($(sm._this).toolset)
  ifeq ($($(sm.var.toolset)),)
    include $(sm.dir.buildsys)/loadtool.mk
  endif

  ifneq ($($(sm.var.toolset)),true)
    $(error smart: $(sm.var.toolset) is not defined)
  endif

  ifneq ($($(sm._this).toolset),common)
    ifeq ($($(sm._this).suffix),)
      ${call sm-check-defined,$(sm.var.toolset).suffix.target.$($(sm._this).type).$(sm.os.name)}
      $(sm._this).suffix := $($(sm.var.toolset).suffix.target.$($(sm._this).type).$(sm.os.name))
    endif
  endif # $(sm._this).toolset != common
endif ## $(sm._this).type != depends

sm.var.temp._header_vars := $(filter $(sm._this).headers.%,$(.VARIABLES))
sm.var.temp._header_vars := $(filter-out \
    %.headers.* \
    %.headers.??? \
   ,$(sm.var.temp._header_vars))

## This is a second check, the first check is done in sm-build-this.
ifeq (${strip \
         $(foreach _,$(sm.var.temp._header_vars),$($_))\
         $($(sm._this).headers)\
         $($(sm._this).sources)\
         $($(sm._this).sources.external)\
         $($(sm._this).depends)\
         $($(sm._this).depends.copyfiles)\
         $($(sm._this).intermediates)},)
  $(error smart: no sources or intermediates or depends for module '$($(sm._this).name)')
endif

ifeq ($($(sm._this).type),t)
 ${if $($(sm._this).lang),,$(error smart: '$(sm._this).lang' must be defined for "tests" module)}
endif

sm.args.docs_format := ${strip $($(sm._this).docs.format)}
ifeq ($(sm.args.docs_format),)
  sm.args.docs_format := .dvi
endif


##################################################

## Clear compile options for all langs
ifneq ($(strip $($(sm._this).type)),depends)
${foreach sm.var.temp._lang,$($(sm.var.toolset).langs),\
  ${eval $(sm._this).compile.flags.$($(sm._this)._cnum).$(sm.var.temp._lang) := }\
  ${eval $(sm._this).compile.flags.$($(sm._this)._cnum).$(sm.var.temp._lang).computed := }}
endif ## $(sm._this).type != depends

$(sm._this)._link.flags :=
$(sm._this)._link.flags.computed :=
$(sm._this)._link.intermediates =
$(sm._this)._link.intermediates.computed :=
$(sm._this)._link.libs :=
$(sm._this)._link.libs.computed :=

$(sm._this).flag_files :=


##################################################

## NOTE: this may slow down the compilation!! The make builtin function "sort"
##       also remove duplicates!
define sm.fun.remove-duplicates
${eval \
  sm.var.temp._var := $(strip $1)
 }\
${eval \
  sm.var.temp._$(sm.var.temp._var) :=
 }\
${foreach sm.var.temp._, $($(sm.var.temp._var)),\
  ${if ${filter $(sm.var.temp._),$(sm.var.temp._$(sm.var.temp._var))},\
      ,${eval sm.var.temp._$(sm.var.temp._var) += $(sm.var.temp._)}\
   }\
 }\
${eval \
  $(sm.var.temp._var) := $(sm.var.temp._$(sm.var.temp._var))
  sm.var.temp._$(sm.var.temp._var) :=
 }
endef #sm.fun.remove-duplicates

##
define sm.fun.remove-sequence-duplicates
${eval \
  sm.var.temp._var := $(strip $1)
 }\
${eval \
  sm.var.temp._$(sm.var.temp._var) :=
 }\
${foreach sm.var.temp._, $($(sm.var.temp._var)),\
   ${eval \
     ifneq ($$(lastword $$(sm.var.temp._$(sm.var.temp._var))),$(sm.var.temp._))
       sm.var.temp._$(sm.var.temp._var) += $(sm.var.temp._)
     endif
    }\
 }\
${eval \
  $(sm.var.temp._var) := $(sm.var.temp._$(sm.var.temp._var))
  sm.var.temp._$(sm.var.temp._var) :=
 }
endef #sm.fun.remove-sequence-duplicates

# vvvvvvv := a b c d e f a a a f b c e g h i j c d
# $(call sm.fun.remove-duplicates,vvvvvvv)
# $(info test: $(vvvvvvv))

# vvvvvvv := a b c d e f a a a f b c e g h i j c d
# $(call sm.fun.remove-sequence-duplicates,vvvvvvv)
# $(info test: $(vvvvvvv))

## eg. $(call sm.fun.append-items,RESULT_VAR_NAME,ITEMS,PREFIX,SUFFIX)
define sm.fun.append-items-with-fix
${foreach sm.var.temp._,$(strip $2),\
  ${eval \
    ## NOTE: sm.var.temp._ may contains commas ",", so must use $$ here
    ifeq ($$(filter $(strip $3)%$(strip $4),$$(sm.var.temp._)),$$(sm.var.temp._))
      $1 += $(sm.var.temp._)
    else
      ifeq ($$(filter $(strip $5),$$(sm.var.temp._)),$$(sm.var.temp._))
        $1 += $(sm.var.temp._)
      else
        $1 += $(strip $3)$(sm.var.temp._:$(strip $3)%$(strip $4)=%)$(strip $4)
      endif
    endif
   }}
endef #sm.fun.append-items-with-fix

##
## eg. $(call sm.code.shift-flags-to-file,compile,flags.c++)
define sm.code.shift-flags-to-file-r
  $(sm._this).$1.flat := $$(subst \",\\\",$$($(sm._this).$1))
  $(sm._this).$1 := @$($(sm._this).out.tmp)/$(1:_%=%)
  $(sm._this).flag_files += $($(sm._this).out.tmp)/$(1:_%=%)
  $($(sm._this).out.tmp)/$(1:_%=%): $($(sm._this).makefile)
	@$$(info smart: flags: $$@)
	@mkdir -p $($(sm._this).out.tmp) && echo $$($(sm._this).$1.flat) > $$@
endef #sm.code.shift-flags-to-file-r
##
define sm.code.shift-flags-to-file
$$(eval $$(call sm.code.shift-flags-to-file-r,$(strip $1),$(strip $2)))
endef #sm.code.shift-flags-to-file

####################

define sm.fun.compute-flags-compile
${eval \
  sm.temp._fvar_prop := compile.flags.$($(sm._this)._cnum).$(sm.var.temp._lang)
  sm.var.temp._fvar_name := $(sm._this).$$(sm.temp._fvar_prop)
 }\
${eval \
  ifeq ($($(sm.var.temp._fvar_name).computed),)
    $(sm.var.temp._fvar_name).computed := true

    ifeq ($($(sm._this).type),t)
      $(sm.var.temp._fvar_name) := -x$($(sm._this).lang)
    else
      $(sm.var.temp._fvar_name) :=
    endif

    $(sm.var.temp._fvar_name) += $(filter %,\
       $($(sm.var.toolset).defines)\
       $($(sm.var.toolset).defines.$(sm.var.temp._lang))\
       $($(sm.var.toolset).compile.flags)\
       $($(sm.var.toolset).compile.flags.$(sm.var.temp._lang))\
       $(sm.global.defines)\
       $(sm.global.defines.$(sm.var.temp._lang))\
       $(sm.global.compile.flags)\
       $(sm.global.compile.flags.$(sm.var.temp._lang))\
       $($(sm._this).used.defines)\
       $($(sm._this).used.defines.$(sm.var.temp._lang))\
       $($(sm._this).used.compile.flags)\
       $($(sm._this).used.compile.flags.$(sm.var.temp._lang))\
       $($(sm._this).defines)\
       $($(sm._this).defines.$(sm.var.temp._lang))\
       $($(sm._this).compile.flags)\
       $($(sm._this).compile.flags.$(sm.var.temp._lang)))

    $$(call sm.fun.append-items-with-fix, $(sm.var.temp._fvar_name), \
           $$($(sm._this).includes) \
           $$($(sm._this).used.includes)\
           $($(sm.var.toolset).includes)\
           $$(sm.global.includes) \
          , -I, , -%)

    $$(call sm.fun.remove-duplicates,$(sm.var.temp._fvar_name))

    ifeq ($(call is-true,$($(sm._this).compile.flags.infile)),true)
      $(call sm.code.shift-flags-to-file,$(sm.temp._fvar_prop))
    endif
  endif
 }
endef #sm.fun.compute-flags-compile

define sm.fun.compute-flags-link
${eval \
  ifeq ($($(sm._this)._link.flags.computed),)
    $(sm._this)._link.flags.computed := true
    $(sm._this)._link.flags := $(filter %,\
       $($(sm.var.toolset).link.flags)\
       $($(sm.var.toolset).link.flags.$($(sm._this).lang))\
       $(sm.global.link.flags)\
       $(sm.global.link.flags.$($(sm._this).lang))\
       $($(sm._this).used.link.flags)\
       $($(sm._this).link.flags)\
       $($(sm._this).link.flags.$($(sm._this).lang)))

    ifeq ($($(sm._this).type),shared)
      $$(if $$(filter -shared,$$($(sm._this)._link.flags)),,\
          $$(eval $(sm._this)._link.flags += -shared))
    endif

    $$(call sm.fun.remove-duplicates,$(sm._this)._link.flags)

    ifeq ($(call is-true,$($(sm._this).link.flags.infile)),true)
      $(call sm.code.shift-flags-to-file,_link.flags)
    endif
  endif
 }
endef #sm.fun.compute-flags-link

define sm.fun.compute-intermediates-link
${eval \
  ifeq ($($(sm._this)._link.intermediates.computed),)
    $(sm._this)._link.intermediates.computed := true
    $(sm._this)._link.intermediates := $(filter %, $($(sm._this).intermediates))

    ifeq ($(call is-true,$($(sm._this).link.intermediates.infile)),true)
      $(call sm.code.shift-flags-to-file,_link.intermediates)
    endif
  endif
 }
endef #sm.fun.compute-intermediates-link

define sm.fun.compute-libs-link
${eval \
  ifeq ($($(sm._this)._link.libs.computed),)
    $(sm._this)._link.libs.computed := true
    $(sm._this)._link.libdirs :=
    $(sm._this)._link.libs :=

    $$(call sm.fun.append-items-with-fix, $(sm._this)._link.libdirs, \
           $$($(sm._this).libdirs) \
           $$($(sm._this).used.libdirs)\
           $$(sm.global.libdirs) \
         , -L, , -% -Wl%)

    $$(call sm.fun.remove-duplicates,$(sm._this)._link.libdirs)

    $$(call sm.fun.append-items-with-fix, $(sm._this)._link.libs, \
           $$(sm.global.libs) \
           $$($(sm._this).libs) \
           $$($(sm._this).used.libs)\
        , -l, , -% -Wl% %.a %.so %.lib %.dll)

    $$(call sm.fun.remove-sequence-duplicates,$(sm._this)._link.libs)

    $(sm._this)._link.libs := \
       $$($(sm._this)._link.libdirs) \
       $$($(sm._this)._link.libs)

    ifeq ($(call is-true,$($(sm._this).libs.infile)),true)
      $(call sm.code.shift-flags-to-file,_link.libs)
    endif
  endif
 }
endef #sm.fun.compute-libs-link

##################################################

## Compute the intermediate name
define sm.fun.compute-intermediate-name
$(strip \
  $(eval sm.var.temp._inter_name := $(sm.var.temp._inter_name:$(sm.top)/%=%))\
  $(eval sm.var.temp._inter_name := $(subst ..,_,$(sm.var.temp._inter_name)))\
$($(sm._this)._intermediate_prefix)$(sm.var.temp._inter_name))
endef #sm.fun.compute-intermediate-name

##
##
define sm.fun.compute-intermediate.
$(strip \
  $(eval sm.var.temp._inter_name := $(sm.var.temp._source))\
  $(eval sm.var.temp._inter_name := $(sm.var.temp._inter_name:$(sm.out.inter)/%=%))\
  $(eval sm.var.temp._inter_name := $(sm.var.temp._inter_name:$($(sm._this)._intermediate_prefix)%=%))\
  $(eval sm.var.temp._inter_name := $(sm.fun.compute-intermediate-name))\
  $(eval sm.var.temp._inter_suff := $(sm.tool.$($(sm._this).toolset).suffix.intermediate.$(sm.var.temp._lang)))\
$(sm.out.inter)/$(sm.var.temp._inter_name)$(sm.var.temp._inter_suff))
endef #sm.fun.compute-intermediate.

define sm.fun.compute-intermediate.external
$(sm.fun.compute-intermediate.)
endef #sm.fun.compute-intermediate.external

define sm.fun.compute-intermediate.common
$(strip \
  $(eval sm.var.temp._inter_name := $(sm.var.temp._source))\
  $(eval sm.var.temp._inter_name := $(sm.var.temp._inter_name:$(sm.out.inter)/common/%=%))\
  $(eval sm.var.temp._inter_name := $(sm.var.temp._inter_name:$($(sm._this)._intermediate_prefix)%=%))\
  $(eval sm.var.temp._inter_name := $(sm.fun.compute-intermediate-name))\
  $(eval sm.var.temp._inter_suff := $(sm.tool.common.suffix.intermediate.$(sm.var.temp._lang).$($(sm._this).lang)))\
$(sm.out.inter)/common/$(sm.var.temp._inter_name)$(sm.var.temp._inter_suff))
endef #sm.fun.compute-intermediate.common

##
## source file of relative location
define sm.fun.compute-source.
${patsubst $(sm.top)/%,%,$($(sm._this).dir)/$(strip $1)}
endef #sm.fun.compute-source.

##
## source file of fixed location
define sm.fun.compute-source.external
$(patsubst $(sm.top)/%,%,$(strip $1))
endef #sm.fun.compute-source.external

##
## binary module to be built
define sm.fun.compute-module-targets-exe
$(patsubst $(sm.top)/%,%,$(sm.out.bin))/$($(sm._this).name)$($(sm._this).suffix)
endef #sm.fun.compute-module-targets-exe

define sm.fun.compute-module-targets-t
$(patsubst $(sm.top)/%,%,$(sm.out.bin))/$($(sm._this).name)$($(sm._this).suffix)
endef #sm.fun.compute-module-targets-t

define sm.fun.compute-module-targets-shared
$(patsubst $(sm.top)/%,%,$(sm.out.bin))/$($(sm._this).name)$($(sm._this).suffix)
endef #sm.fun.compute-module-targets-shared

define sm.fun.compute-module-targets-static
$(patsubst $(sm.top)/%,%,$(sm.out.lib))/lib$($(sm._this).name:lib%=%)$($(sm._this).suffix)
endef #sm.fun.compute-module-targets-static

##################################################

ifneq ($(and $(call is-true,$($(sm._this).gen_deps)),\
             $(call not-equal,$(MAKECMDGOALS),clean)),)
define sm.fun.make-rule-depend
  ${eval sm.var.temp._depend := $(sm.var.temp._intermediate:%.o=%$($(sm._this).depend.suffixes))}\
  ${eval \
    -include $(sm.var.temp._depend)
    $(sm._this).depends += $(sm.var.temp._depend)

    ifeq ($(call is-true,$($(sm._this).compile.flags.infile)),true)
      sm.var.temp._flag_file := $($(sm._this).out.tmp)/compile.flags.$($(sm._this)._cnum).$(sm.var.temp._lang)
    else
      sm.var.temp._flag_file :=
    endif

    sm.args.output := $(sm.var.temp._depend)
    sm.args.target := $(sm.var.temp._intermediate)
    sm.args.sources := $(call sm.fun.compute-source.$1,$(sm.var.temp._source))
    sm.args.prerequisites = $(sm.args.sources)
    sm.args.flags.0 := $($(sm._this).compile.flags.$($(sm._this)._cnum).$(sm.var.temp._lang))
    sm.args.flags.0 += $(strip $($(sm._this).compile.flags-$(sm.var.temp._source)))
    sm.args.flags.1 :=
    sm.args.flags.2 :=
  }${eval \
   ifeq ($(sm.global.has.rule.$(sm.args.output)),)
    ifeq ($(wildcard $(sm.args.sources)),)
      #$$(info smart: missing $(sm.args.sources) ($($(sm._this).name)))
    endif
    sm.global.has.rule.$(sm.args.output) := true
    $(sm.args.output) : $(sm.var.temp._flag_file) $(sm.args.sources)
	$$(call sm-util-mkdir,$$(@D))
	$(if $(call equal,$($(sm._this).verbose),true),,\
          $$(info smart: update $(sm.args.output))\
          $(sm.var.Q))$(filter %, $(sm.tool.$($(sm._this).toolset).dependency.$(sm.args.lang)))
   endif
  }
endef #sm.fun.make-rule-depend
else
  sm.fun.make-rule-depend :=
endif #if $(sm._this).gen_deps && MAKECMDGOALS != clean

## Make rule for building object
##   eg. $(call sm.fun.make-rule-compile)
##   eg. $(call sm.fun.make-rule-compile, external)
##   eg. $(call sm.fun.make-rule-compile, intermediate)
define sm.fun.make-rule-compile
 $(if $(sm.var.temp._lang),,$(error smart: internal: $$(sm.var.temp._lang) is empty))\
 $(if $(sm.var.temp._source),,$(error smart: internal: $$(sm.var.temp._source) is empty))\
 $(if $1,$(call sm-check-equal,$(strip $1),external,smart: arg \#3 must be 'external' if specified))\
 $(call sm-check-defined,sm.fun.compute-source.$(strip $1), smart: I donot know how to compute sources of lang '$(sm.var.temp._lang)$(if $1,($(strip $1)))')\
 $(call sm-check-defined,sm.fun.compute-intermediate.$(strip $1), smart: I donot how to compute intermediates of lang '$(sm.var.temp._lang)$(if $1,($(strip $1)))')\
 $(eval sm.var.temp._intermediate := $(sm.fun.compute-intermediate.$(strip $1)))\
 $(eval $(sm._this).intermediates += $(sm.var.temp._intermediate))\
 $(call sm.fun.make-rule-depend,$1)\
 $(eval \
   sm.args.target := $(sm.var.temp._intermediate)
   sm.args.sources := $(call sm.fun.compute-source.$(strip $1),$(sm.var.temp._source))
   sm.args.prerequisites = $$(sm.args.sources)
   sm.args.flags.0 := $($(sm._this).compile.flags.$($(sm._this)._cnum).$(sm.var.temp._lang))
   sm.args.flags.0 += $($(sm._this).compile.flags-$(sm.var.temp._source))
   sm.args.flags.1 :=
   sm.args.flags.2 :=

   ifeq ($(call is-true,$($(sm._this).compile.flags.infile)),true)
     $(sm.args.target) : $($(sm._this).out.tmp)/compile.flags.$($(sm._this)._cnum).$(sm.var.temp._lang)
   endif
  )$(sm-rule-compile-$(sm.var.temp._lang))
endef #sm.fun.make-rule-compile

## 
define sm.fun.make-rule-compile-common-command
$(strip $(if $(call equal,$($(sm._this).verbose),true),$2,\
   $$(info $1: $($(sm._this).name) += $$^ --> $$@)$(sm.var.Q)($2)>/dev/null))
endef #sm.fun.make-rule-compile-common-command

##
define sm.fun.make-rule-compile-common
 $(if $(sm.var.temp._lang),,$(error smart: internal: $$(sm.var.temp._lang) is empty))\
 $(if $(sm.var.temp._source),,$(error smart: internal: $$(sm.var.temp._source) is empty))\
 $(eval ## Compute output file and literal output languages\
   ## target output file language, e.g. Parscal, C, C++, TeX, etc.
   sm.var.temp._output_lang := $(sm.tool.common.lang.intermediate.$(sm.var.temp._lang).$($(sm._this).lang))
   ## literal output file language, e.g. TeX, LaTeX, etc.
   sm.var.temp._literal_lang := $(sm.tool.common.lang.intermediate.literal.$(sm.var.temp._lang))
  )\
 $(eval sm.var.temp._intermediate := $(sm.fun.compute-intermediate.common))\
 $(if $(and $(call not-equal,$(sm.var.temp._literal_lang),$(sm.var.temp._lang)),
            $(sm.var.temp._output_lang)),$(eval \
   ## args for sm.tool.common.compile.*
   sm.args.lang = $($(sm._this).lang)
   sm.args.target := $(sm.var.temp._intermediate)
   sm.args.sources := $(sm.var.temp._source)
   sm.args.prerequisites = $(sm.args.sources)
  )$(eval \
   ## If $(sm.var.temp._source) is possible to be transformed into another lang.
   $(sm._this).sources.$(sm.var.temp._output_lang) += $(sm.args.target)
   $(sm._this).sources.has.$(sm.var.temp._output_lang) := true
   ## Make rule for generating intermediate file (e.g. cweb to c compilation)
   ifeq ($(sm.global.has.rule.$(sm.args.target)),)
     sm.global.has.rule.$(sm.args.target) := true
     $(sm.args.target) : $(sm.args.sources)
	@[[ -d $$(@D) ]] || mkdir -p $$(@D)
	$(call sm.fun.make-rule-compile-common-command,$(sm.var.temp._lang),\
            $(filter %, $(sm.tool.common.compile.$(sm.var.temp._lang))))
   endif
  ))\
 $(if $(sm.var.temp._literal_lang),\
  $(if $(call not-equal,$(sm.var.temp._literal_lang),$(sm.var.temp._lang)),\
    $(eval \
      ## If source can have literal(.tex) output...
      # TODO: should use sm.args.targets to including .tex, .idx, .scn files
      sm.args.target := $(basename $(sm.var.temp._intermediate))$(sm.tool.common.suffix.intermediate.$(sm.var.temp._lang).$(sm.var.temp._literal_lang))
      sm.args.sources := $(sm.var.temp._source)
      sm.args.prerequisites = $(sm.args.sources)
     )$(eval ## compilate rule for documentation sources(.tex files)
      #TODO: rules for producing .tex sources ($(sm.var.temp._literal_lang))
      $(sm._this).sources.$(sm.var.temp._literal_lang) += $(sm.args.target)
      $(sm._this).sources.has.$(sm.var.temp._literal_lang) := true
      ifeq ($$(filter $(sm.var.temp._literal_lang),$$($(sm.var.toolset).langs) $$(sm.var.common.langs) $$(sm.var.common.langs.extra)),)
        sm.var.common.langs.extra += $(sm.var.temp._literal_lang)
      endif
      ifeq ($(sm.global.has.rule.$(sm.args.target)),)
        sm.global.has.rule.$(sm.args.target) := true
      $(sm.args.target) : $(sm.args.sources)
	@[[ -d $$(@D) ]] || mkdir -p $$(@D)
	$(call sm.fun.make-rule-compile-common-command,$(sm.var.temp._lang),\
            $(filter %, $(sm.tool.common.compile.literal.$(sm.var.temp._lang))))
      endif
     ))\
  $(if $(call equal,$(sm.var.temp._literal_lang),$(sm.var.temp._lang)),\
    $(eval \
      sm.args.sources := $(sm.var.temp._source)
      sm.args.prerequisites = $(sm.args.sources)
      sm.args.target := $(sm.out.doc)/$(notdir $(basename $(sm.var.temp._source)))$(sm.args.docs_format)
     )\
    $(eval # rules for producing .dvi/.pdf(depends on sm.args.docs_format) files
      ifneq ($(sm.global.has.rule.$(sm.args.target)),true)
        sm.global.has.rule.$(sm.args.target) := true
        $(sm._this).documents += $(sm.args.target)
       $(sm.args.target) : $(sm.args.sources)
	@[[ -d $$(@D) ]] || mkdir -p $$(@D)
	$(call sm.fun.make-rule-compile-common-command,$(sm.var.temp._lang),\
            $(filter %, $(sm.tool.common.compile.$(sm.var.temp._literal_lang))))
	@[[ -f $$@ ]] || (echo "ERROR: $(sm.var.temp._lang): no document output: $$@" && true)
      endif
     )))
endef #sm.fun.make-rule-compile-common

##
## Make object rules, eg. $(call sm.fun.make-rules-compile,c++)
##
## Computes sources of a specific languange via sm.var.temp._temp and generate
## compilation rules for them.
define sm.fun.make-rules-compile
$(if $(sm.var.temp._lang),,$(error smart: internal: sm.var.temp._lang is empty))\
$(eval \
 ifeq ($$($(sm._this).sources.has.$(sm.var.temp._lang)),true)
  $$(foreach sm.var.temp._source,$$($(sm._this).sources.$(sm.var.temp._lang)),$$(call sm.fun.make-rule-compile))
  $$(foreach sm.var.temp._source,$$($(sm._this).sources.external.$(sm.var.temp._lang)),$$(call sm.fun.make-rule-compile,external))
 endif
 )
endef #sm.fun.make-rules-compile

## Same as sm.fun.make-rules-compile, but the common source file like 'foo.w'
## may generate output like 'out/common/foo.cpp', this will be then appended
## to $(sm._this).sources.c++ which will then be used by sm.fun.make-rules-compile.
define sm.fun.make-rules-compile-common
$(if $(sm.var.temp._lang),,$(error smart: internal: $$(sm.var.temp._lang) is empty))\
$(if $($(sm._this).sources.has.$(sm.var.temp._lang)),\
    $(foreach sm.var.temp._source,$($(sm._this).sources.$(sm.var.temp._lang)),\
       $(call sm.fun.make-rule-compile-common)))
endef #sm.fun.make-rules-compile-common

##################################################

##
##
define sm.fun.check-strange-and-compute-common-source
$(eval \
  sm.var.temp._tool4src := $(strip $(sm.toolset.for.file$(suffix $(sm.var.temp._source))))
  sm.var.temp._is_strange_source := $$(call not-equal,$$(sm.var.temp._tool4src),$($(sm._this).toolset))
  ######
  ifeq ($(suffix $(sm.var.temp._source)),.t)
    sm.var.temp._is_strange_source :=
  endif
  ######
  ifeq ($$(sm.var.temp._is_strange_source),true)
    sm.var.temp._check_common_langs := $(sm.tool.common.langs)
  else
    sm.var.temp._check_common_langs :=
  endif
 )\
$(foreach _,$(sm.var.temp._check_common_langs),\
   $(if $(filter $(suffix $(sm.var.temp._source)),$(sm.tool.common.suffix.$_)),\
       $(eval \
         sm.var.temp._is_strange_source :=
         $(sm._this).sources.has.$_ := true
         ######
         ifeq ($(filter $(sm.var.temp._source),$($(sm._this).sources.common)),)
           $(sm._this).sources.common += $(sm.var.temp._source)
         endif
         ######
         ifeq ($(filter $(sm.var.temp._source),$($(sm._this).sources.$_)),)
           $(sm._this).sources.$_ += $(sm.var.temp._source)
         endif
         ######
         ifeq ($(filter $_,$(sm.var.common.langs)),)
           sm.var.common.langs += $_
         endif
         sm.var.common.lang$(suffix $(sm.var.temp._source)) := $_
        )))\
$(eval \
  ifeq ($(sm.var.temp._is_strange_source),true)
    $$(warning error: "$(sm.var.temp._source)" is not supported by toolset "$($(sm._this).toolset)")
    $(sm._this).sources.unknown += $(sm.var.temp._source)
  endif
 )
endef #sm.fun.check-strange-and-compute-common-source

##
##
define sm.fun.make-common-compile-rules-for-langs
${foreach sm.var.temp._lang,$1,\
   $(if $(sm.tool.common.suffix.$(sm.var.temp._lang)),\
      ,$(error smart: toolset $($(sm._this).toolset)/$(sm.var.temp._lang) has no suffixes))\
   $(eval $(sm._this).sources.$(sm.var.temp._lang) = $($(sm._this).sources.$(sm.var.temp._lang)))\
   $(call sm.fun.compute-flags-compile)\
   $(sm.fun.make-rules-compile-common)}
endef #sm.fun.make-common-compile-rules-for-langs

##################################################

#-----------------------------------------------
#-----------------------------------------------

## Check strange sources and compute common sources.
sm.var.common.langs :=
sm.var.common.langs.extra :=
$(sm._this).sources.common :=
$(sm._this).sources.unknown :=
ifneq ($(strip $($(sm._this).type)),depends)
  $(foreach sm.var.temp._source, $($(sm._this).sources) $($(sm._this).sources.external),\
      $(sm.fun.check-strange-and-compute-common-source))
endif ## $(sm._this).type != depends

## Export computed common sources.
$(sm._this).sources.common := $(strip $($(sm._this).sources.common))

## Export computed common sources of different language and make compile rules
## for common sources(files not handled by the toolset, e.g. .w, .nw, etc).
$(call sm.fun.make-common-compile-rules-for-langs,$(sm.var.common.langs))
$(call sm.fun.make-common-compile-rules-for-langs,$(sm.var.common.langs.extra))

ifneq ($(strip $($(sm._this).type)),depends)
## Make compile rules for sources of each lang supported by the selected toolset.
## E.g. $(sm._this).sources.$(sm.var.temp._lang)
${foreach sm.var.temp._lang,$($(sm.var.toolset).langs),\
  $(if $($(sm.var.toolset).suffix.$(sm.var.temp._lang)),\
      ,$(error smart: toolset $($(sm._this).toolset)/$(sm.var.temp._lang) has no suffixes))\
  $(call sm.fun.compute-flags-compile)\
  $(sm.fun.make-rules-compile)\
  $(if $(and $(call equal,$(strip $($(sm._this).lang)),),\
             $($(sm._this).sources.has.$(sm.var.temp._lang))),\
         $(no-info smart: language choosed as "$(sm.var.temp._lang)" for "$($(sm._this).name)")\
         $(eval $(sm._this).lang := $(sm.var.temp._lang))\
   )\
 }
endif ## $(sm._this).type != depends

## Make object rules for .t sources file
ifeq ($($(sm._this).type),t)
  # set sm.var.temp._lang for sm.fun.make-rule-compile
  sm.var.temp._lang := $($(sm._this).lang)

  $(sm._this).sources.$(sm.var.temp._lang).t := $(filter %.t,$($(sm._this).sources))
  $(sm._this).sources.external.$(sm.var.temp._lang).t := $(filter %.t,$($(sm._this).sources.external))
  $(sm._this).sources.has.$(sm.var.temp._lang).t := $(if $($(sm._this).sources.$(sm.var.temp._lang).t)$($(sm._this).sources.external.$(sm.var.temp._lang).t),true)

  ifeq ($(or $($(sm._this).sources.has.$(sm.var.temp._lang)),$($(sm._this).sources.has.$(sm.var.temp._lang).t)),true)
    ${foreach sm.var.temp._source,$($(sm._this).sources.$(sm.var.temp._lang).t),$(call sm.fun.make-rule-compile)}
    ${foreach sm.var.temp._source,$($(sm._this).sources.external.$(sm.var.temp._lang).t),$(call sm.fun.make-rule-compile,external)}
  endif
endif # $(sm._this).type == t

sm.var.temp._should_make_targets := \
  $(if $(or $(call not-equal,$(strip $($(sm._this).sources.unknown)),),\
            $(call equal,$(strip $($(sm._this).type)),depends),\
            $(call equal,$(strip $($(sm._this).intermediates)),),\
            $(call is-true,$($(sm._this)._intermediates_only)))\
        ,,true)

##-----------------------------------
## make static, shared, exe, t targets
ifneq ($($(sm._this).toolset),common)
ifeq ($(sm.var.temp._should_make_targets),true)
  ifeq ($($(sm._this).lang),)
    $(error smart: $(sm._this).lang is empty)
  endif

  ## Make rule for targets of the module
  $(if $($(sm._this).intermediates),,$(error smart: no intermediates for building '$($(sm._this).name)'))

  $(call sm-check-defined,$(sm._this)._link.flags)
  $(call sm-check-defined,$(sm._this)._link.intermediates)
  $(call sm-check-defined,$(sm._this)._link.libs)
  $(call sm-check-defined,sm-rule-$(sm.var.action)-$($(sm._this).lang))
  $(call sm-check-defined,sm.fun.compute-flags-link)
  $(call sm-check-defined,sm.fun.compute-intermediates-link)
  $(call sm-check-defined,sm.fun.compute-libs-link)
  $(call sm-check-defined,sm.fun.compute-module-targets-$($(sm._this).type))

  $(sm._this).targets := $(sm.fun.compute-module-targets-$($(sm._this).type))
  $(sm._this).targets := $(strip $($(sm._this).targets))

  $(sm.fun.compute-flags-link)
  $(sm.fun.compute-intermediates-link)
  $(sm.fun.compute-libs-link)

  sm.var.temp._flag_file_prefix := $($(sm._this).out.tmp)/link
  sm.var.temp._flag_files :=

  ifeq ($(call is-true,$($(sm._this).link.flags.infile)),true)
    sm.var.temp._flag_files += $(sm.var.temp._flag_file_prefix).flags
  endif ## flags.infile == true

  ifeq ($(call is-true,$($(sm._this).link.intermediates.infile)),true)
    sm.var.temp._flag_files += $(sm.var.temp._flag_file_prefix).intermediates
  endif ## intermediates.infile == true

  ifeq ($(call is-true,$($(sm._this).libs.infile)),true)
    ifeq (link,link)
      sm.var.temp._flag_files += $(sm.var.temp._flag_file_prefix).libs
    endif
  endif ## libs.infile == true

  ifneq ($(sm.var.temp._flag_files),)
    $(sm.args.target) : $(sm.var.temp._flag_files)
  endif # $(sm.var.temp._flag_files) != ""

  sm.args.target := $($(sm._this).targets)
  sm.args.sources := $($(sm._this)._link.intermediates)
  sm.args.prerequisites := $($(sm._this).intermediates)
  sm.args.flags.0 := $($(sm._this)._link.flags)
  sm.args.flags.1 := $($(sm._this)._link.libs)
  $(sm-rule-$(sm.var.action)-$($(sm._this).lang))

  ifeq ($(strip $($(sm._this).targets)),)
    $(error smart: internal error: targets mis-computed)
  endif
endif #$(sm.var.temp._should_make_targets) == true
endif #$($(sm._this).toolset) != common

#-----------------------------------------------
#-----------------------------------------------

$(sm._this).module_targets := $($(sm._this).targets)
$(sm._this).targets += $($(sm._this).user_defined_targets)
$(sm._this).inters = $($(sm._this).intermediates)

##################################################
# copy headers
##################################################

## this is the final headers to be copied
$(sm._this).headers.??? :=

## sm-copy-files will append to this
sm.this.depends.copyfiles_saved := $(sm.this.depends.copyfiles)
sm.this.depends.copyfiles :=

## headers from sm.this.headers
ifneq ($(call is-true,$($(sm._this).headers!)),true)
  ifneq ($($(sm._this).headers),)
    $(call sm-copy-files, $($(sm._this).headers), $(sm.out.inc))
    $(sm._this).headers.??? += $(foreach _,$($(sm._this).headers),$(sm.out.inc)/$_)
  endif # $(sm._this).headers != ""
endif # $(sm._this).headers! == true

$(sm._this).headers.* := $(filter-out * ???,\
    $(sm.var.temp._header_vars:$(sm._this).headers.%=%))

## select multipart headers:
##     sm.this.headers.* := foo bar
##     sm.this.headers.foo := foo.h # copy to foo/foo.h
##     sm.this.headers.bar := bar.h # copy to bar/bar.h
ifneq ($($(sm._this).headers.*),)
define sm.fun.copy-headers
$(eval \
    ifneq ($(call is-true,$($(sm._this).headers.$(sm.var.temp._hp)!)),true)
    ifneq ($($(sm._this).headers.$(sm.var.temp._hp)),)
      $$(call sm-copy-files, $($(sm._this).headers.$(sm.var.temp._hp)), $(sm.out.inc)/$(sm.var.temp._hp))
      $(sm._this).headers.??? += $(foreach _, $($(sm._this).headers.$(sm.var.temp._hp)),$(sm.out.inc)/$(sm.var.temp._hp)/$_)
    endif # $(sm._this).headers.$(sm.var.temp._hp)! != true
    endif # $(sm._this).headers.$(sm.var.temp._hp) != ""
 )
endef #sm.fun.copy-headers
  $(foreach sm.var.temp._hp, $($(sm._this).headers.*), $(sm.fun.copy-headers))
  sm.fun.copy-headers = $(error smart: internal: sm.fun.copy-headers is private)
endif # $(sm._this).headers.* != ""

## export the final copy rule
ifneq ($($(sm._this).headers.???),)
  $(sm._this).depends.copyfiles += $(sm.this.depends.copyfiles)
  headers-$($(sm._this).name) : $($(sm._this).headers.???)
endif # $(sm._this).headers.copied != ""

## must restore sm.this.depends.copyfiles
sm.this.depends.copyfiles := $(sm.this.depends.copyfiles_saved)

##################################################
##################################################
ifeq ($(strip $($(sm._this).type)),depends)
  goal-$($(sm._this).name): \
    $($(sm._this).depends) \
    $($(sm._this).depends.copyfiles) \
    $($(sm._this).targets) #; @echo "smart: $@, $^"
  clean-$($(sm._this).name):
	$(call sm.tool.common.rm, $($(sm._this).depends) $($(sm._this).depends.copyfiles))
  $(eval doc-$($(sm._this).name) : ; @echo "smart: No documents for $($(sm._this).name).")
endif ## $(sm._this).type != depends

ifeq ($(sm.var.temp._should_make_targets),true)
  ifeq ($(strip $($(sm._this).intermediates)),)
    $(warning smart: no intermediates)
  endif

ifeq ($(MAKECMDGOALS),clean)
  goal-$($(sm._this).name) : ; @true
  doc-$($(sm._this).name) : ; @true
  headers-$($(sm._this).name) : ; @true
else
  ifneq ($($(sm._this).documents),)
    doc-$($(sm._this).name) : $($(sm._this).documents)
  else
    $(eval doc-$($(sm._this).name) : ; @echo "smart: No documents for $($(sm._this).name).")
  endif

  goal-$($(sm._this).name) : \
    $($(sm._this).depends) \
    $($(sm._this).depends.copyfiles) \
    $($(sm._this).targets)
endif # MAKECMDGOALS != clean

ifeq ($($(sm._this).type),t)
  define sm.code.make-test-rules
    sm.global.tests += test-$($(sm._this).name)
    test-$($(sm._this).name): $($(sm._this).targets)
	@echo test: $($(sm._this).name) - $$< && $$<
  endef #sm.code.make-test-rules
  $(eval $(sm.code.make-test-rules))
endif ## $($(sm._this).type) == t

$(call sm-check-not-empty, sm.tool.common.rm)
$(call sm-check-not-empty, sm.tool.common.rmdir)
define sm.fun.make-clean-rules
$(eval \
  clean-$($(sm._this).name): \
    clean-$($(sm._this).name)-flags \
    clean-$($(sm._this).name)-targets \
    clean-$($(sm._this).name)-intermediates \
    clean-$($(sm._this).name)-depends \
    $($(sm._this).clean-steps)
	@echo "smart: \"$$(@:clean-%=%)\" is clean"

  sm.rules.phony.* += \
    clean-$($(sm._this).name) \
    clean-$($(sm._this).name)-flags \
    clean-$($(sm._this).name)-targets \
    clean-$($(sm._this).name)-intermediates \
    clean-$($(sm._this).name)-depends \
    $($(sm._this).clean-steps)

  ifeq ($(call is-true,$($(sm._this).verbose)),true)
    clean-$($(sm._this).name)-flags:
	$$(call sm.tool.common.rm,$$($(sm._this).flag_files))
    clean-$($(sm._this).name)-targets:
	$$(call sm.tool.common.rm,$$($(sm._this).targets))
    clean-$($(sm._this).name)-intermediates:
	$$(call sm.tool.common.rm,$$($(sm._this).intermediates))
    clean-$($(sm._this).name)-depends:
	$$(call sm.tool.common.rm,$$($(sm._this).depends))
  else
    clean-$($(sm._this).name)-flags:
	@$$(info remove:$($(sm._this).targets))$$(call sm.tool.common.rm,$$($(sm._this).flag_files))
    clean-$($(sm._this).name)-targets:
	@$$(info remove:$($(sm._this).targets))$$(call sm.tool.common.rm,$$($(sm._this).targets))
    clean-$($(sm._this).name)-intermediates:
	@$$(info remove:$($(sm._this).intermediates))$$(call sm.tool.common.rm,$$($(sm._this).intermediates))
    clean-$($(sm._this).name)-depends:
	@$$(info remove:$($(sm._this).depends))$$(call sm.tool.common.rm,$$($(sm._this).depends))
  endif
 )
endef #sm.fun.make-clean-rules
$(sm.fun.make-clean-rules)

sm.var.temp._built_mk := $(sm.dir.buildsys)/tools/$($(sm._this).toolset)/built-target.mk
sm.var.temp._built_mk := $(wildcard $(sm.var.temp._built_mk))
ifdef sm.var.temp._built_mk
  include $(sm.var.temp._built_mk)
endif #sm.var.temp._built_mk
endif # sm.var.temp._should_make_targets == true

##################################################
##################################################
