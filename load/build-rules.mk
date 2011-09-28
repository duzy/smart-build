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

ifeq ($(sm._var_.this),)
  $(error smart: internal: sm._var_.this is empty)
endif

ifeq ($(sm._fun_.this),)
  $(error smart: internal: sm._fun_.this is empty)
endif

$(call sm-check-not-empty,sm.this.toolset,smart: 'sm.this.toolset' for $(sm.this.name) unknown)

##################################################

sm.var.action.static := archive
sm.var.action.shared := link
sm.var.action.exe := link
sm.var.action.t := link
sm.var.depend.suffixes.static := .d
sm.var.depend.suffixes.shared := .d
sm.var.depend.suffixes.exe := .d
sm.var.depend.suffixes.t := .t.d

## for sm.this.using: recursive loading
ifeq ($($(sm._var_.this).name),)
  $(sm._var_.this).name := $(sm.this.name)
  $(sm._var_.this).type := $(sm.this.type)
  $(sm._var_.this).toolset := $(sm.this.toolset)
  $(sm._var_.this).action := $(sm.var.action.$(sm.this.type))
  $(sm._var_.this).depend.suffixes := $(sm.var.depend.suffixes.$(sm.this.type))
  $(sm._var_.this).user_defined_targets := $(strip $(sm.this.targets))
  $(sm._var_.this).out.tmp := $(sm.out.tmp)/$(sm.this.name)

  $(sm._var_.this)._intermediate_prefix := $(sm.this.dir:$(sm.top)%=%)
  $(sm._var_.this)._intermediate_prefix := $($(sm._var_.this)._intermediate_prefix:%.=%)
  $(sm._var_.this)._intermediate_prefix := $($(sm._var_.this)._intermediate_prefix:/%=%)
  ifneq ($($(sm._var_.this)._intermediate_prefix),)
    $(sm._var_.this)._intermediate_prefix := $($(sm._var_.this)._intermediate_prefix)/
  endif

  # BUG: wrong if more than one sm-build-this occurs in a smart.mk
  #$(warning $(sm.this.name): $($(sm._var_.this)._intermediate_prefix))
endif # $(sm._var_.this).name == ""

#-----------------------------------------------
#-----------------------------------------------

ifneq ($(sm.this.using),)
  $(warning using: $(sm.this.using))
endif

##################################################

sm.var.toolset := sm.tool.$($(sm._var_.this).toolset)
ifeq ($($(sm.var.toolset)),)
  include $(sm.dir.buildsys)/loadtool.mk
endif

ifneq ($($(sm.var.toolset)),true)
  $(error smart: $(sm.var.toolset) is not defined)
endif

ifneq ($($(sm._var_.this).toolset),common)
  ifeq ($(sm.this.suffix),)
    $(call sm-check-defined,$(sm.var.toolset).target.suffix.$(sm.os.name).$(sm.this.type))
    sm.this.suffix := $($(sm.var.toolset).target.suffix.$(sm.os.name).$(sm.this.type))
  endif
endif

ifeq ($(strip $(sm.this.sources)$(sm.this.sources.external)$(sm.this.intermediates)),)
  $(error smart: no sources or intermediates for module '$(sm.this.name)')
endif

ifeq ($(sm.this.type),t)
 $(if $(sm.this.lang),,$(error smart: 'sm.this.lang' must be defined for "tests" module))
endif

sm.args.docs_format := $(strip $(sm.this.docs.format))
ifeq ($(sm.args.docs_format),)
  sm.args.docs_format := .dvi
endif

##################################################

## Clear compile options for all langs
$(foreach sm.var.temp._lang,$($(sm.var.toolset).langs),\
  $(eval $(sm._var_.this).compile.$($(sm._var_.this)._cnum).flags.$(sm.var.temp._lang) := )\
  $(eval $(sm._var_.this).compile.$($(sm._var_.this)._cnum).flags.$(sm.var.temp._lang).computed := ))

## unset sm.var.temp._lang, the name may be used later
sm.var.temp._lang :=

$(sm._var_.this).archive.flags :=
$(sm._var_.this).archive.flags.computed :=
$(sm._var_.this).archive.intermediates =
$(sm._var_.this).archive.intermediates.computed :=
$(sm._var_.this).archive.libs :=
$(sm._var_.this).archive.libs.computed :=
$(sm._var_.this).link.flags :=
$(sm._var_.this).link.flags.computed :=
$(sm._var_.this).link.intermediates =
$(sm._var_.this).link.intermediates.computed :=
$(sm._var_.this).link.libs :=
$(sm._var_.this).link.libs.computed :=

$(sm._var_.this).flag_files :=

##################################################

## make list of only one space separated items
define sm.fun.make-pretty-list
$(strip $(eval sm.var.temp._pretty_list :=)\
  $(foreach _,$1,$(eval sm.var.temp._pretty_list += $(strip $_)))\
  $(sm.var.temp._pretty_list))
endef #sm.fun.make-pretty-list

## eg. $(call sm.fun.append-items,RESULT_VAR_NAME,ITEMS,PREFIX,SUFFIX)
define sm.fun.append-items
$(foreach sm.var.temp._item,$(strip $2),\
  $(eval $(strip $1) += $(strip $3)$(sm.var.temp._item:$(strip $3)%$(strip $4)=%)$(strip $4)))
endef #sm.fun.append-items

##
## eg. $(call sm.code.shift-flags-to-file,compile,flags.c++)
define sm.code.shift-flags-to-file-r
 ifeq ($(call is-true,$(sm.this.$1.flags.infile)),true)
  $(sm._var_.this).$1.$2.flat := $$(subst \",\\\",$$($(sm._var_.this).$1.$2))
  $(sm._var_.this).$1.$2 := @$($(sm._var_.this).out.tmp)/$1.$2
  $(sm._var_.this).flag_files += $($(sm._var_.this).out.tmp)/$1.$2
  $($(sm._var_.this).out.tmp)/$1.$2: $(sm.this.makefile)
	@$$(info smart: flag file: $$@)
	@mkdir -p $($(sm._var_.this).out.tmp)
	@echo $$($(sm._var_.this).$1.$2.flat) > $$@
 endif
endef #sm.code.shift-flags-to-file-r
##
define sm.code.shift-flags-to-file
$$(eval $$(call sm.code.shift-flags-to-file-r,$(strip $1),$(strip $2)))
endef #sm.code.shift-flags-to-file

####################

define sm.fun.compute-flags-compile
$(eval \
  sm.var.temp._fvar_name := $(sm._var_.this).compile.$($(sm._var_.this)._cnum).flags.$(sm.var.temp._lang)
 )\
$(eval \
  ifeq ($($(sm.var.temp._fvar_name).computed),)
    $(sm.var.temp._fvar_name).computed := true
    $(sm.var.temp._fvar_name) := $(call sm.fun.make-pretty-list,\
       $(if $(call equal,$(sm.this.type),t),-x$(sm.this.lang))\
       $($(sm.var.toolset).defines)\
       $($(sm.var.toolset).defines.$(sm.var.temp._lang))\
       $($(sm.var.toolset).compile.flags)\
       $($(sm.var.toolset).compile.flags.$(sm.var.temp._lang))\
       $(sm.global.defines)\
       $(sm.global.defines.$(sm.var.temp._lang))\
       $(sm.global.compile.flags)\
       $(sm.global.compile.flags.$(sm.var.temp._lang))\
       $(sm.this.defines)\
       $(sm.this.defines.$(sm.var.temp._lang))\
       $(sm.this.compile.flags)\
       $(sm.this.compile.flags.$(sm.var.temp._lang)))
    $$(call sm.fun.append-items,$(sm.var.temp._fvar_name),\
       $(sm.global.includes) $(sm.this.includes), -I)
    $(call sm.code.shift-flags-to-file,compile,$($(sm._var_.this)._cnum).flags.$(sm.var.temp._lang))
  endif
 )
endef #sm.fun.compute-flags-compile

define sm.fun.compute-flags-archive
$(eval \
  ifeq ($($(sm._var_.this).archive.flags.computed),)
    $(sm._var_.this).archive.flags.computed := true
    $(sm._var_.this).archive.flags := \
      $(call sm.fun.make-pretty-list,\
        $(sm.global.archive.flags)\
        $(sm.this.archive.flags))
    $(call sm.code.shift-flags-to-file,archive,flags)
  endif
 )
endef #sm.fun.compute-flags-archive

define sm.fun.compute-flags-link
$(eval \
  ifeq ($($(sm._var_.this).link.flags.computed),)
    $(sm._var_.this).link.flags.computed := true
    $(sm._var_.this).link.flags := $(call sm.fun.make-pretty-list,\
       $($(sm.var.toolset).link.flags)\
       $(sm.global.link.flags)\
       $(sm.this.link.flags))
    ifeq ($(sm.this.type),shared)
      $$(if $$(filter -shared,$$($(sm._var_.this).link.flags)),,\
          $$(eval $(sm._var_.this).link.flags += -shared))
    endif
    $(call sm.code.shift-flags-to-file,link,flags)
  endif
 )
endef #sm.fun.compute-flags-link

define sm.fun.compute-intermediates-archive
$(eval \
  ifeq ($($(sm._var_.this).archive.intermediates.computed),)
    $(sm._var_.this).archive.intermediates.computed := true
    $(sm._var_.this).archive.intermediates := $($(sm._var_.this).intermediates)
    $(call sm.code.shift-flags-to-file,archive,intermediates)
  endif
 )
endef #sm.fun.compute-intermediates-archive

define sm.fun.compute-libs-archive
$(eval \
  $(sm._var_.this).archive.libs.computed := true
  $(sm._var_.this).archive.libs :=
 )
endef #sm.fun.compute-libs-archive

define sm.fun.compute-intermediates-link
$(eval \
  ifeq ($($(sm._var_.this).link.intermediates.computed),)
    $(sm._var_.this).link.intermediates.computed := true
    $(sm._var_.this).link.intermediates := $($(sm._var_.this).intermediates)
    $(call sm.code.shift-flags-to-file,link,intermediates)
  endif
 )
endef #sm.fun.compute-intermediates-link

define sm.fun.compute-libs-link
$(eval \
  ifeq ($($(sm._var_.this).link.libs.computed),)
    $(sm._var_.this).link.libs.computed := true
    $(sm._var_.this).link.libs :=
    $$(call sm.fun.append-items, $(sm._var_.this).link.libs,$(sm.global.libdirs) $(sm.this.libdirs), -L)
    $$(call sm.fun.append-items, $(sm._var_.this).link.libs,$(sm.global.libs) $(sm.this.libs), -l)
    $(call sm.code.shift-flags-to-file,link,libs)
  endif
 )
endef #sm.fun.compute-libs-link

##################################################

## Compute the intermediate name without suffix.
define sm.fun.compute-intermediate-name
$($(sm._var_.this)._intermediate_prefix)$(basename $(subst ..,_,$(call sm-relative-path,$(sm.var.temp._source))))
endef #sm.fun.compute-intermediate-name

##
##
define sm.fun.compute-intermediate.
$(sm.out.inter)/$(sm.fun.compute-intermediate-name)$(sm.tool.$($(sm._var_.this).toolset).intermediate.suffix.$(sm.var.temp._lang))
endef #sm.fun.compute-intermediate.

define sm.fun.compute-intermediate.external
$(sm.fun.compute-intermediate.)
endef #sm.fun.compute-intermediate.external

define sm.fun.compute-intermediate.common
$(sm.out.inter)/common/$(sm.fun.compute-intermediate-name)$(sm.tool.common.intermediate.suffix.$(sm.var.temp._lang).$(sm.this.lang))
endef #sm.fun.compute-intermediate.common

##
## source file of relative location
define sm.fun.compute-source.
$(call sm-relative-path,$(sm.this.dir)/$(strip $1))
endef #sm.fun.compute-source.

##
## source file of fixed location
define sm.fun.compute-source.external
$(call sm-relative-path,$(strip $1))
endef #sm.fun.compute-source.external

##
## binary module to be built
define sm.fun.compute-module-targets-exe
$(call sm-relative-path,$(sm.out.bin))/$(sm.this.name)$(sm.this.suffix)
endef #sm.fun.compute-module-targets-exe

define sm.fun.compute-module-targets-t
$(call sm-relative-path,$(sm.out.bin))/$(sm.this.name)$(sm.this.suffix)
endef #sm.fun.compute-module-targets-t

define sm.fun.compute-module-targets-shared
$(call sm-relative-path,$(sm.out.bin))/$(sm.this.name)$(sm.this.suffix)
endef #sm.fun.compute-module-targets-shared

define sm.fun.compute-module-targets-static
$(call sm-relative-path,$(sm.out.lib))/lib$(sm.this.name:lib%=%)$(sm.this.suffix)
endef #sm.fun.compute-module-targets-static

##################################################

ifneq ($(and $(call is-true,$(sm.this.gen_deps)),\
             $(call not-equal,$(MAKECMDGOALS),clean)),)
define sm.fun.make-rule-depend
  $(eval sm.var.temp._depend := $(sm.var.temp._intermediate:%.o=%$($(sm._var_.this).depend.suffixes)))\
  $(eval \
    -include $(sm.var.temp._depend)
    $(sm._var_.this).depends += $(sm.var.temp._depend)

    ifeq ($(call is-true,$(sm.this.compile.flags.infile)),true)
      sm.var.temp._flag_file := $($(sm._var_.this).out.tmp)/compile.$($(sm._var_.this)._cnum).flags.$(sm.var.temp._lang)
    else
      sm.var.temp._flag_file :=
    endif

    sm.args.output := $(sm.var.temp._depend)
    sm.args.target := $(sm.var.temp._intermediate)
    sm.args.sources := $(call sm.fun.compute-source.$1,$(sm.var.temp._source))
    sm.args.flags.0 := $($(sm._var_.this).compile.$($(sm._var_.this)._cnum).flags.$(sm.var.temp._lang))
    sm.args.flags.0 += $(strip $(sm.this.compile.flags-$(sm.var.temp._source)))
    sm.args.flags.1 :=
    sm.args.flags.2 :=
  )$(eval \
   ifeq ($(sm.global.has.rule.$(sm.args.output)),)
    sm.global.has.rule.$(sm.args.output) := true
    $(sm.args.output) : $(sm.var.temp._flag_file) $(sm.args.sources)
	$$(call sm-util-mkdir,$$(@D))
	$(if $(call equal,$(sm.this.verbose),true),,\
          $$(info smart: update $(sm.args.output))\
          $(sm.var.Q))$(sm.tool.$($(sm._var_.this).toolset).dependency.$(sm.args.lang))
   endif
  )
endef #sm.fun.make-rule-depend
else
  sm.fun.make-rule-depend :=
endif #if sm.this.gen_deps && MAKECMDGOALS != clean

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
 $(eval $(sm._var_.this).intermediates += $(sm.var.temp._intermediate))\
 $(call sm.fun.make-rule-depend,$1)\
 $(eval \
   sm.args.target := $(sm.var.temp._intermediate)
   sm.args.sources := $(call sm.fun.compute-source.$(strip $1),$(sm.var.temp._source))
   sm.args.flags.0 := $($(sm._var_.this).compile.$($(sm._var_.this)._cnum).flags.$(sm.var.temp._lang))
   sm.args.flags.0 += $(sm.this.compile.flags-$(sm.var.temp._source))
   sm.args.flags.1 :=
   sm.args.flags.2 :=

   ifeq ($(call is-true,$(sm.this.compile.flags.infile)),true)
     $(sm.args.target) : $($(sm._var_.this).out.tmp)/compile.$($(sm._var_.this)._cnum).flags.$(sm.var.temp._lang)
   endif

   $$(sm-rule-compile-$(sm.var.temp._lang))
 )
endef #sm.fun.make-rule-compile

## 
define sm.fun.make-rule-compile-common-command
$(strip $(if $(call equal,$(sm.this.verbose),true),$2,\
   $$(info $1: $(sm.this.name) += $$^ --> $$@)$(sm.var.Q)($2)>/dev/null))
endef #sm.fun.make-rule-compile-common-command

##
define sm.fun.make-rule-compile-common
 $(if $(sm.var.temp._lang),,$(error smart: internal: $$(sm.var.temp._lang) is empty))\
 $(if $(sm.var.temp._source),,$(error smart: internal: $$(sm.var.temp._source) is empty))\
 $(eval ## Compute output file and literal output languages\
   ## target output file language, e.g. Parscal, C, C++, TeX, etc.
   sm.var.temp._output_lang := $(sm.tool.common.intermediate.lang.$(sm.var.temp._lang).$(sm.this.lang))
   ## literal output file language, e.g. TeX, LaTeX, etc.
   sm.var.temp._literal_lang := $(sm.tool.common.intermediate.lang.literal.$(sm.var.temp._lang))
  )\
 $(eval sm.var.temp._intermediate := $(sm.fun.compute-intermediate.common))\
 $(if $(and $(call not-equal,$(sm.var.temp._literal_lang),$(sm.var.temp._lang)),
            $(sm.var.temp._output_lang)),$(eval \
   ## args for sm.tool.common.compile.*
   sm.args.lang = $(sm.this.lang)
   sm.args.target := $(sm.var.temp._intermediate)
   sm.args.sources := $(sm.var.temp._source)
  )$(eval \
   ## If $(sm.var.temp._source) is possible to be transformed into another lang.
   sm.this.sources.$(sm.var.temp._output_lang) += $(sm.args.target)
   sm.this.sources.has.$(sm.var.temp._output_lang) := true
   ## Make rule for generating intermediate file (e.g. cweb to c compilation)
   ifeq ($(sm.global.has.rule.$(sm.args.target)),)
     sm.global.has.rule.$(sm.args.target) := true
     $(sm.args.target) : $(sm.args.sources)
	@[[ -d $$(@D) ]] || mkdir -p $$(@D)
	$(call sm.fun.make-rule-compile-common-command,$(sm.var.temp._lang),\
            $(sm.tool.common.compile.$(sm.var.temp._lang)))
   endif
  ))\
 $(if $(sm.var.temp._literal_lang),\
  $(if $(call not-equal,$(sm.var.temp._literal_lang),$(sm.var.temp._lang)),\
    $(eval \
      ## If source can have literal(.tex) output...
      # TODO: should use sm.args.targets to including .tex, .idx, .scn files
      sm.args.target := $(basename $(sm.var.temp._intermediate))$(sm.tool.common.intermediate.suffix.$(sm.var.temp._lang).$(sm.var.temp._literal_lang))
      sm.args.sources := $(sm.var.temp._source)
     )$(eval ## compilate rule for documentation sources(.tex files)
      #TODO: rules for producing .tex sources ($(sm.var.temp._literal_lang))
      sm.this.sources.$(sm.var.temp._literal_lang) += $(sm.args.target)
      sm.this.sources.has.$(sm.var.temp._literal_lang) := true
      ifeq ($$(filter $(sm.var.temp._literal_lang),$$($(sm.var.toolset).langs) $$(sm.var.common.langs) $$(sm.var.common.langs.extra)),)
        sm.var.common.langs.extra += $(sm.var.temp._literal_lang)
      endif
      ifeq ($(sm.global.has.rule.$(sm.args.target)),)
        sm.global.has.rule.$(sm.args.target) := true
      $(sm.args.target) : $(sm.args.sources)
	@[[ -d $$(@D) ]] || mkdir -p $$(@D)
	$(call sm.fun.make-rule-compile-common-command,$(sm.var.temp._lang),\
            $(sm.tool.common.compile.literal.$(sm.var.temp._lang)))
      endif
     ))\
  $(if $(call equal,$(sm.var.temp._literal_lang),$(sm.var.temp._lang)),\
    $(eval \
      sm.args.sources := $(sm.var.temp._source)
      sm.args.target := $(sm.out.doc)/$(notdir $(basename $(sm.var.temp._source)))$(sm.args.docs_format)
     )\
    $(eval # rules for producing .dvi/.pdf(depends on sm.args.docs_format) files
      ifneq ($(sm.global.has.rule.$(sm.args.target)),true)
        sm.global.has.rule.$(sm.args.target) := true
        $(sm._var_.this).documents += $(sm.args.target)
       $(sm.args.target) : $(sm.args.sources)
	@[[ -d $$(@D) ]] || mkdir -p $$(@D)
	$(call sm.fun.make-rule-compile-common-command,$(sm.var.temp._lang),\
            $(sm.tool.common.compile.$(sm.var.temp._literal_lang)))
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
 ifeq ($$(sm.this.sources.has.$(sm.var.temp._lang)),true)
  $$(foreach sm.var.temp._source,$$(sm.this.sources.$(sm.var.temp._lang)),$$(call sm.fun.make-rule-compile))
  $$(foreach sm.var.temp._source,$$(sm.this.sources.external.$(sm.var.temp._lang)),$$(call sm.fun.make-rule-compile,external))
 endif
 $(null))
endef #sm.fun.make-rules-compile

## Same as sm.fun.make-rules-compile, but the common source file like 'foo.w'
## may generate output like 'out/common/foo.cpp', this will be then appended
## to sm.this.sources.c++ which will then be used by sm.fun.make-rules-compile.
define sm.fun.make-rules-compile-common
$(if $(sm.var.temp._lang),,$(error smart: internal: $$(sm.var.temp._lang) is empty))\
$(if $(sm.this.sources.has.$(sm.var.temp._lang)),\
    $(foreach sm.var.temp._source,$(sm.this.sources.$(sm.var.temp._lang)),\
       $(call sm.fun.make-rule-compile-common)))
endef #sm.fun.make-rules-compile-common

##################################################

$(sm._var_.this).targets :=

ifeq ($($(sm._var_.this)._compile_count),)
  ## in case that only sm-build-this (no sm-compile-sources) is called
  $(sm._var_.this)._compile_count := 1
endif # $($(sm._var_.this)._compile_count) is empty

## If first time building this...
ifeq ($($(sm._var_.this)._compile_count),1)
  ## clear these vars only once (see sm-compile-sources)
  $(sm._var_.this).sources :=
  $(sm._var_.this).sources.unknown :=
  $(sm._var_.this).intermediates := $(sm.this.intermediates)
  $(sm._var_.this).depends :=
endif

##
define sm.fun.compute-sources-by-lang
$(eval \
  sm.var.temp._suffix_pat.$(sm.var.temp._lang)  := $($(sm.var.toolset).$(sm.var.temp._lang).suffix:%=\%%)
  sm.this.sources.$(sm.var.temp._lang)          := $$(filter $$(sm.var.temp._suffix_pat.$(sm.var.temp._lang)),$(sm.this.sources))
  sm.this.sources.external.$(sm.var.temp._lang) := $$(filter $$(sm.var.temp._suffix_pat.$(sm.var.temp._lang)),$(sm.this.sources.external))
  sm.this.sources.has.$(sm.var.temp._lang)      := $$(if $$(sm.this.sources.$(sm.var.temp._lang))$$(sm.this.sources.external.$(sm.var.temp._lang)),true)
 )
endef #sm.fun.compute-sources-for-lang

##
##
define sm.fun.check-strange-and-compute-common-source
$(eval \
  sm.var.temp._tool4src := $(strip $(sm.toolset.for.file$(suffix $(sm.var.temp._source))))
  sm.var.temp._is_strange_source := $$(call not-equal,$$(sm.var.temp._tool4src),$($(sm._var_.this).toolset))
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
   $(if $(filter $(suffix $(sm.var.temp._source)),$(sm.tool.common.$_.suffix)),\
       $(eval \
         sm.var.temp._is_strange_source :=
         sm.this.sources.has.$_ := true
         ######
         ifeq ($(filter $(sm.var.temp._source),$(sm.this.sources.common)),)
           sm.this.sources.common += $(sm.var.temp._source)
         endif
         ######
         ifeq ($(filter $(sm.var.temp._source),$(sm.this.sources.$_)),)
           sm.this.sources.$_ += $(sm.var.temp._source)
         endif
         ######
         ifeq ($(filter $_,$(sm.var.common.langs)),)
           sm.var.common.langs += $_
         endif
         sm.var.common.lang$(suffix $(sm.var.temp._source)) := $_
        )))\
$(eval \
  ifeq ($(sm.var.temp._is_strange_source),true)
    $$(warning warning: "$(sm.var.temp._source)" is unsupported by toolset "$($(sm._var_.this).toolset)")
    sm.this.sources.unknown += $(sm.var.temp._source)
  endif
 )
endef #sm.fun.check-strange-and-compute-common-source

##
##
define sm.fun.make-common-compile-rules-for-langs
$(foreach sm.var.temp._lang,$1,\
   $(if $(sm.tool.common.$(sm.var.temp._lang).suffix),\
      ,$(error smart: toolset $($(sm._var_.this).toolset)/$(sm.var.temp._lang) has no suffixes))\
   $(eval $(sm._var_.this).sources.$(sm.var.temp._lang) := $(sm.this.sources.$(sm.var.temp._lang)))\
   $(call sm.fun.compute-flags-compile)\
   $(sm.fun.make-rules-compile-common))
endef #sm.fun.make-common-compile-rules-for-langs

##################################################

#-----------------------------------------------
#-----------------------------------------------

## Compute sources of each language supported by the toolset.
$(foreach sm.var.temp._lang,$($(sm.var.toolset).langs),\
    $(sm.fun.compute-sources-by-lang))

## Check strange sources and compute common sources.
sm.var.common.langs :=
sm.var.common.langs.extra :=
sm.this.sources.common :=
sm.this.sources.unknown :=
$(foreach sm.var.temp._source, $(sm.this.sources) $(sm.this.sources.external),\
    $(sm.fun.check-strange-and-compute-common-source))

## Export computed common sources.
sm.this.sources.common := $(strip $(sm.this.sources.common))
$(sm._var_.this).sources.common := $(sm.this.sources.common)

## (FIXME: this may be no sense!).
$(sm._var_.this).sources.unknown := $(sm.this.sources.unknown)

## Export computed common sources of different language and make compile rules
## for common sources(files not handled by the toolset, e.g. .w, .nw, etc).
$(call sm.fun.make-common-compile-rules-for-langs,$(sm.var.common.langs))
$(call sm.fun.make-common-compile-rules-for-langs,$(sm.var.common.langs.extra))

## Make compile rules for sources of each lang supported by the selected toolset.
## E.g. sm.this.sources.$(sm.var.temp._lang)
$(foreach sm.var.temp._lang,$($(sm.var.toolset).langs),\
  $(if $($(sm.var.toolset).$(sm.var.temp._lang).suffix),\
      ,$(error smart: toolset $($(sm._var_.this).toolset)/$(sm.var.temp._lang) has no suffixes))\
  $(eval $(sm._var_.this).sources.$(sm.var.temp._lang) := $(sm.this.sources.$(sm.var.temp._lang)))\
  $(call sm.fun.compute-flags-compile)\
  $(sm.fun.make-rules-compile)\
  $(if $(and $(call equal,$(strip $($(sm._var_.this).lang)),),\
             $(sm.this.sources.has.$(sm.var.temp._lang))),\
         $(info smart: language choosed as "$(sm.var.temp._lang)" for "$(sm.this.name)")\
         $(eval $(sm._var_.this).lang := $(sm.var.temp._lang))))

## Make object rules for .t sources file
ifeq ($(sm.this.type),t)
  # set sm.var.temp._lang, used by sm.fun.make-rule-compile
  sm.var.temp._lang := $(sm.this.lang)
  sm.this.sources.$(sm.var.temp._lang).t := $(filter %.t,$(sm.this.sources))
  sm.this.sources.external.$(sm.var.temp._lang).t := $(filter %.t,$(sm.this.sources.external))
  sm.this.sources.has.$(sm.var.temp._lang).t := $(if $(sm.this.sources.$(sm.var.temp._lang).t)$(sm.this.sources.external.$(sm.var.temp._lang).t),true)
  ifeq ($(or $(sm.this.sources.has.$(sm.var.temp._lang)),$(sm.this.sources.has.$(sm.var.temp._lang).t)),true)
    $(foreach sm.var.temp._source,$(sm.this.sources.$(sm.var.temp._lang).t),$(call sm.fun.make-rule-compile))
    $(foreach sm.var.temp._source,$(sm.this.sources.external.$(sm.var.temp._lang).t),$(call sm.fun.make-rule-compile,external))
    ifeq ($($(sm._var_.this).lang),)
      $(sm._var_.this).lang := $(sm.this.lang)
    endif
  endif
endif

sm.var.temp._should_make_targets := \
  $(if $(or $(call not-equal,$(strip $(sm.this.sources.unknown)),),\
            $(call equal,$(strip $($(sm._var_.this).intermediates)),),\
            $(call is-true,$($(sm._var_.this)._intermediates_only))\
        ),,true)

ifneq ($($(sm._var_.this).toolset),common)
ifeq ($(sm.var.temp._should_make_targets),true)
 ## Make rule for targets of the module
  $(if $($(sm._var_.this).intermediates),,$(error smart: no intermediates for building '$(sm.this.name)'))

  $(call sm-check-defined,$(sm._var_.this).action)
  $(call sm-check-defined,$(sm._var_.this).lang)
  $(call sm-check-defined,sm-rule-$($(sm._var_.this).action)-$($(sm._var_.this).lang))
  $(call sm-check-defined,sm.fun.compute-flags-$($(sm._var_.this).action))
  $(call sm-check-defined,sm.fun.compute-intermediates-$($(sm._var_.this).action))
  $(call sm-check-defined,sm.fun.compute-libs-$($(sm._var_.this).action))
  $(call sm-check-defined,sm.fun.compute-module-targets-$(sm.this.type))

  $(call sm-check-defined,sm-rule-$($(sm._var_.this).action)-$($(sm._var_.this).lang))
  $(call sm-check-defined,$(sm._var_.this).$($(sm._var_.this).action).flags)
  $(call sm-check-defined,$(sm._var_.this).$($(sm._var_.this).action).intermediates)
  $(call sm-check-defined,$(sm._var_.this).$($(sm._var_.this).action).libs)
  $(call sm-check-not-empty,$(sm._var_.this).lang)

  $(sm._var_.this).targets := $(strip $(call sm.fun.compute-module-targets-$(sm.this.type)))

  $(sm.fun.compute-flags-$($(sm._var_.this).action))
  $(sm.fun.compute-intermediates-$($(sm._var_.this).action))
  $(sm.fun.compute-libs-$($(sm._var_.this).action))

  sm.args.target := $($(sm._var_.this).targets)
  sm.args.sources := $($(sm._var_.this).intermediates)
  sm.args.flags.0 := $($(sm._var_.this).$($(sm._var_.this).action).flags)
  sm.args.flags.1 := $($(sm._var_.this).$($(sm._var_.this).action).libs)

  $(sm-rule-$($(sm._var_.this).action)-$($(sm._var_.this).lang))

  ifeq ($(strip $($(sm._var_.this).targets)),)
    $(error smart: internal error: targets mis-computed)
  endif
endif #$(sm.var.temp._should_make_targets) == true
endif #$($(sm._var_.this).toolset) != common

#-----------------------------------------------
#-----------------------------------------------

$(sm._var_.this).module_targets := $($(sm._var_.this).targets)
$(sm._var_.this).targets += $($(sm._var_.this).user_defined_targets)
$(sm._var_.this).inters = $($(sm._var_.this).intermediates)
sm.this.intermediates = $($(sm._var_.this).intermediates)
sm.this.inters = $(sm.this.intermediates)
sm.this.depends = $($(sm._var_.this).depends)
sm.this.targets = $($(sm._var_.this).targets)
sm.this.documents = $($(sm._var_.this).documents)

##################################################
##################################################

ifeq ($(sm.var.temp._should_make_targets),true)

ifeq ($(strip $($(sm._var_.this).intermediates)),)
  $(warning smart: no intermediates)
endif

ifeq ($(MAKECMDGOALS),clean)
  goal-$(sm.this.name) : ; @true
  doc-$(sm.this.name) : ; @true
else
  goal-$(sm.this.name) : \
    $(sm.this.depends) \
    $(sm.this.depends.copyfiles) \
    $($(sm._var_.this).targets)

  ifneq ($($(sm._var_.this).documents),)
    doc-$(sm.this.name) : $($(sm._var_.this).documents)
  else
    doc-$(sm.this.name) : ; @echo smart: No documents for $(sm.this.name).
  endif
endif

ifeq ($(sm.this.type),t)
  define sm.code.make-test-rules
    sm.global.tests += test-$(sm.this.name)
    test-$(sm.this.name): $($(sm._var_.this).targets)
	@echo test: $(sm.this.name) - $$< && $$<
  endef #sm.code.make-test-rules
  $(eval $(sm.code.make-test-rules))
endif

$(call sm-check-not-empty, sm.tool.common.rm)
$(call sm-check-not-empty, sm.tool.common.rmdir)

clean-$(sm.this.name): \
  clean-$(sm.this.name)-flags \
  clean-$(sm.this.name)-targets \
  clean-$(sm.this.name)-intermediates \
  clean-$(sm.this.name)-depends \
  $(sm.this.clean-steps)
	@echo "'$(@:clean-%=%)' is cleaned."

define sm.code.clean-rules
sm.rules.phony.* += \
    clean-$(sm.this.name) \
    clean-$(sm.this.name)-flags \
    clean-$(sm.this.name)-targets \
    clean-$(sm.this.name)-intermediates \
    clean-$(sm.this.name)-depends \
    $(sm.this.clean-steps)
clean-$(sm.this.name)-flags:
	$(if $(call is-true,$(sm.this.verbose)),,$$(info remove:$($(sm._var_.this).targets))@)$$(call sm.tool.common.rm,$$($(sm._var_.this).flag_files))
clean-$(sm.this.name)-targets:
	$(if $(call is-true,$(sm.this.verbose)),,$$(info remove:$($(sm._var_.this).targets))@)$$(call sm.tool.common.rm,$$($(sm._var_.this).targets))
clean-$(sm.this.name)-intermediates:
	$(if $(call is-true,$(sm.this.verbose)),,$$(info remove:$($(sm._var_.this).intermediates))@)$$(call sm.tool.common.rm,$$($(sm._var_.this).intermediates))
clean-$(sm.this.name)-depends:
	$(if $(call is-true,$(sm.this.verbose)),,$$(info remove:$($(sm._var_.this).depends))@)$$(call sm.tool.common.rm,$$($(sm._var_.this).depends))
endef #sm.code.clean-rules

$(eval $(sm.code.clean-rules))

endif # sm.var.temp._should_make_targets == true

##################################################
##################################################
