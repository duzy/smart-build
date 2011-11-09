#
#
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
##
define sm.fun.compute-sources-by-lang
  ${eval \
  sm.var.temp._suffix_pat.$(sm.var.lang)  := $($(sm.var.tool).suffix.$(sm.var.lang):%=\%%)
  $(sm._this).sources.$(sm.var.lang)          := $$(filter $$(sm.var.temp._suffix_pat.$(sm.var.lang)),$($(sm._this).sources))
  $(sm._this).sources.external.$(sm.var.lang) := $$(filter $$(sm.var.temp._suffix_pat.$(sm.var.lang)),$($(sm._this).sources.external))
  $(sm._this).sources.has.$(sm.var.lang)      := $$(if $$($(sm._this).sources.$(sm.var.lang))$$($(sm._this).sources.external.$(sm.var.lang)),true)
  }
endef #sm.fun.compute-sources-by-lang

define sm.fun.compute-flags-compile
${eval \
  sm.temp._fvar_prop := compile.flags.$($(sm._this)._cnum).$(sm.var.lang)
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
       $($(sm.var.tool).defines)\
       $($(sm.var.tool).defines.$(sm.var.lang))\
       $($(sm.var.tool).compile.flags)\
       $($(sm.var.tool).compile.flags.$(sm.var.lang))\
       $(sm.global.defines)\
       $(sm.global.defines.$(sm.var.lang))\
       $(sm.global.compile.flags)\
       $(sm.global.compile.flags.$(sm.var.lang))\
       $($(sm._this).used.defines)\
       $($(sm._this).used.defines.$(sm.var.lang))\
       $($(sm._this).used.compile.flags)\
       $($(sm._this).used.compile.flags.$(sm.var.lang))\
       $($(sm._this).defines)\
       $($(sm._this).defines.$(sm.var.lang))\
       $($(sm._this).compile.flags)\
       $($(sm._this).compile.flags.$(sm.var.lang)))

    $$(call sm.fun.append-items-with-fix, $(sm.var.temp._fvar_name), \
           $$($(sm._this).includes) \
           $$($(sm._this).used.includes)\
           $($(sm.var.tool).includes)\
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
       $($(sm.var.tool).link.flags)\
       $($(sm.var.tool).link.flags.$($(sm._this).lang))\
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
  $(eval sm.var.temp._inter_suff := $(sm.tool.$($(sm._this).toolset).suffix.intermediate.$(sm.var.lang)))\
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
  $(eval sm.var.temp._inter_suff := $(sm.tool.common.suffix.intermediate.$(sm.var.lang).$($(sm._this).lang)))\
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

define sm.fun.do-make-rule-depend
  ${eval sm.var.temp._depend := $(sm.var.temp._intermediate:%.o=%.d)}\
  ${eval \
    -include $(sm.var.temp._depend)
    $(sm._this).depends += $(sm.var.temp._depend)

    ifeq ($(call is-true,$($(sm._this).compile.flags.infile)),true)
      sm.var.temp._flag_file := $($(sm._this).out.tmp)/compile.flags.$($(sm._this)._cnum).$(sm.var.lang)
    else
      sm.var.temp._flag_file :=
    endif

    sm.args.output := $(sm.var.temp._depend)
    sm.args.target := $(sm.var.temp._intermediate)
    sm.args.sources := $(call sm.fun.compute-source.$1,$(sm.var.temp._source))
    sm.args.prerequisites = $(sm.args.sources)
    sm.args.flags.0 := $($(sm._this).compile.flags.$($(sm._this)._cnum).$(sm.var.lang))
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
endef #sm.fun.do-make-rule-depend

## Make rule for building object
##   eg. $(call sm.fun.make-rule-compile)
##   eg. $(call sm.fun.make-rule-compile, external)
##   eg. $(call sm.fun.make-rule-compile, intermediate)
define sm.fun.make-rule-compile
 $(if $(sm.var.lang),,$(error smart: internal: $$(sm.var.lang) is empty))\
 $(if $(sm.var.temp._source),,$(error smart: internal: $$(sm.var.temp._source) is empty))\
 $(if $1,$(call sm-check-equal,$(strip $1),external,smart: arg \#3 must be 'external' if specified))\
 $(call sm-check-defined,sm.fun.compute-source.$(strip $1), smart: I donot know how to compute sources of lang '$(sm.var.lang)$(if $1,($(strip $1)))')\
 $(call sm-check-defined,sm.fun.compute-intermediate.$(strip $1), smart: I donot how to compute intermediates of lang '$(sm.var.lang)$(if $1,($(strip $1)))')\
 $(eval sm.var.temp._intermediate := $(sm.fun.compute-intermediate.$(strip $1)))\
 $(eval $(sm._this).intermediates += $(sm.var.temp._intermediate))\
 $(call sm.fun.make-rule-depend,$1)\
 $(eval \
   ifneq ($(and $(call is-true,$($(sm._this).gen_deps)),\
                $(call not-equal,$(MAKECMDGOALS),clean)),)
     $$(do-make-rule-depend)
   endif

   sm.args.target := $(sm.var.temp._intermediate)
   sm.args.sources := $(call sm.fun.compute-source.$(strip $1),$(sm.var.temp._source))
   sm.args.prerequisites = $$(sm.args.sources)
   sm.args.flags.0 := $($(sm._this).compile.flags.$($(sm._this)._cnum).$(sm.var.lang))
   sm.args.flags.0 += $($(sm._this).compile.flags-$(sm.var.temp._source))
   sm.args.flags.1 :=
   sm.args.flags.2 :=

   ifeq ($(call is-true,$($(sm._this).compile.flags.infile)),true)
     $(sm.args.target) : $($(sm._this).out.tmp)/compile.flags.$($(sm._this)._cnum).$(sm.var.lang)
   endif
  )$(sm-rule-compile-$(sm.var.lang))
endef #sm.fun.make-rule-compile

## 
define sm.fun.make-rule-compile-common-command
$(strip $(if $(call equal,$($(sm._this).verbose),true),$2,\
   $$(info $1: $($(sm._this).name) += $$^ --> $$@)$(sm.var.Q)($2)>/dev/null))
endef #sm.fun.make-rule-compile-common-command

##
define sm.fun.make-rule-compile-common
 $(if $(sm.var.lang),,$(error smart: internal: $$(sm.var.lang) is empty))\
 $(if $(sm.var.temp._source),,$(error smart: internal: $$(sm.var.temp._source) is empty))\
 $(eval ## Compute output file and literal output languages\
   ## target output file language, e.g. Parscal, C, C++, TeX, etc.
   sm.var.temp._output_lang := $(sm.tool.common.lang.intermediate.$(sm.var.lang).$($(sm._this).lang))
   ## literal output file language, e.g. TeX, LaTeX, etc.
   sm.var.temp._literal_lang := $(sm.tool.common.lang.intermediate.literal.$(sm.var.lang))
  )\
 $(eval sm.var.temp._intermediate := $(sm.fun.compute-intermediate.common))\
 $(if $(and $(call not-equal,$(sm.var.temp._literal_lang),$(sm.var.lang)),
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
	$(call sm.fun.make-rule-compile-common-command,$(sm.var.lang),\
            $(filter %, $(sm.tool.common.compile.$(sm.var.lang))))
   endif
  ))\
 $(if $(sm.var.temp._literal_lang),\
  $(if $(call not-equal,$(sm.var.temp._literal_lang),$(sm.var.lang)),\
    $(eval \
      ## If source can have literal(.tex) output...
      # TODO: should use sm.args.targets to including .tex, .idx, .scn files
      sm.args.target := $(basename $(sm.var.temp._intermediate))$(sm.tool.common.suffix.intermediate.$(sm.var.lang).$(sm.var.temp._literal_lang))
      sm.args.sources := $(sm.var.temp._source)
      sm.args.prerequisites = $(sm.args.sources)
     )$(eval ## compilate rule for documentation sources(.tex files)
      #TODO: rules for producing .tex sources ($(sm.var.temp._literal_lang))
      $(sm._this).sources.$(sm.var.temp._literal_lang) += $(sm.args.target)
      $(sm._this).sources.has.$(sm.var.temp._literal_lang) := true
      ifeq ($$(filter $(sm.var.temp._literal_lang),$$(sm.var.langs) $$(sm.var.common.langs) $$(sm.var.common.langs.extra)),)
        sm.var.common.langs.extra += $(sm.var.temp._literal_lang)
      endif
      ifeq ($(sm.global.has.rule.$(sm.args.target)),)
        sm.global.has.rule.$(sm.args.target) := true
      $(sm.args.target) : $(sm.args.sources)
	@[[ -d $$(@D) ]] || mkdir -p $$(@D)
	$(call sm.fun.make-rule-compile-common-command,$(sm.var.lang),\
            $(filter %, $(sm.tool.common.compile.literal.$(sm.var.lang))))
      endif
     ))\
  $(if $(call equal,$(sm.var.temp._literal_lang),$(sm.var.lang)),\
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
	$(call sm.fun.make-rule-compile-common-command,$(sm.var.lang),\
            $(filter %, $(sm.tool.common.compile.$(sm.var.temp._literal_lang))))
	@[[ -f $$@ ]] || (echo "ERROR: $(sm.var.lang): no document output: $$@" && true)
      endif
     )))
endef #sm.fun.make-rule-compile-common

##
## Make object rules, eg. $(call sm.fun.make-rules-compile,c++)
##
## Computes sources of a specific languange via sm.var.temp._temp and generate
## compilation rules for them.
define sm.fun.make-rules-compile
$(if $(sm.var.lang),,$(error smart: internal: sm.var.lang is empty))\
$(eval \
 ifeq ($$($(sm._this).sources.has.$(sm.var.lang)),true)
  $$(foreach sm.var.temp._source,$$($(sm._this).sources.$(sm.var.lang)),$$(call sm.fun.make-rule-compile))
  $$(foreach sm.var.temp._source,$$($(sm._this).sources.external.$(sm.var.lang)),$$(call sm.fun.make-rule-compile,external))
 endif
 )
endef #sm.fun.make-rules-compile

## Same as sm.fun.make-rules-compile, but the common source file like 'foo.w'
## may generate output like 'out/common/foo.cpp', this will be then appended
## to $(sm._this).sources.c++ which will then be used by sm.fun.make-rules-compile.
define sm.fun.make-rules-compile-common
$(if $(sm.var.lang),,$(error smart: internal: $$(sm.var.lang) is empty))\
$(if $($(sm._this).sources.has.$(sm.var.lang)),\
    $(foreach sm.var.temp._source,$($(sm._this).sources.$(sm.var.lang)),\
       $(call sm.fun.make-rule-compile-common)))
endef #sm.fun.make-rules-compile-common

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
${foreach sm.var.lang,$1,\
   $(if $(sm.tool.common.suffix.$(sm.var.lang)),\
      ,$(error smart: toolset $($(sm._this).toolset)/$(sm.var.lang) has no suffixes))\
   $(eval $(sm._this).sources.$(sm.var.lang) = $($(sm._this).sources.$(sm.var.lang)))\
   $(call sm.fun.compute-flags-compile)\
   $(sm.fun.make-rules-compile-common)}
endef #sm.fun.make-common-compile-rules-for-langs

##################################################

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

define sm.fun.make-test-rules
$(eval \
  sm.global.tests += test-$($(sm._this).name)
  test-$($(sm._this).name): $($(sm._this).targets)
	@echo test: $($(sm._this).name) - $$< && $$<
 )
endef #sm.fun.make-test-rules

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

