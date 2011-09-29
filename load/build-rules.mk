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
endif

##################################################

sm.var.action.static := archive
sm.var.action.shared := link
sm.var.action.exe := link
sm.var.action.t := link
sm.var.depend.suffixes.static := .d
sm.var.depend.suffixes.shared := .d
sm.var.depend.suffixes.exe := .d
sm.var.depend.suffixes.t := .t.d

## clone module from sm.this for sm.this.using/sm-use-module: recursive loading
#ifeq ($($(sm._this).name),)
  $(call sm-clone-module, sm.this, $(sm._this))
#endif # $(sm._this).name == ""

## check module name
ifeq ($($(sm._this).name),)
  $(error smart: internal: $(sm._this).name is empty)
endif # $(sm._this).name == ""

## configure the module if not yet done
#ifneq ($(sm._this)._configured,true)
  $(sm._this)._configured := true

  $(sm._this).action := $(sm.var.action.$(sm.this.type))
  $(sm._this).depend.suffixes := $(sm.var.depend.suffixes.$(sm.this.type))
  $(sm._this).user_defined_targets := $(strip $(sm.this.targets))
  $(sm._this).out.tmp := $(sm.out.tmp)/$(sm.this.name)

  $(sm._this)._intermediate_prefix := $($(sm._this).dir:$(sm.top)%=%)
  $(sm._this)._intermediate_prefix := $($(sm._this)._intermediate_prefix:%.=%)
  $(sm._this)._intermediate_prefix := $($(sm._this)._intermediate_prefix:/%=%)
  ifneq ($($(sm._this)._intermediate_prefix),)
    $(sm._this)._intermediate_prefix := $($(sm._this)._intermediate_prefix)/
  endif

  # BUG: wrong if more than one sm-build-this occurs in a smart.mk
  #$(warning $(sm.this.name): $($(sm._this)._intermediate_prefix))
#endif #$(sm._this)._configured == ""

##
## $(sm._this)._should_compute_sources will be "true" on each
## sm-build-this and sm-compile-sources calling.
#ifeq ($($(sm._this)._should_compute_sources),true)
  define sm.fun.compute-sources-by-lang
  $(eval \
  sm.var.temp._suffix_pat.$(sm.var.temp._lang)  := $($(sm.var.toolset).$(sm.var.temp._lang).suffix:%=\%%)
  $(sm._this).sources.$(sm.var.temp._lang)          := $$(filter $$(sm.var.temp._suffix_pat.$(sm.var.temp._lang)),$($(sm._this).sources))
  $(sm._this).sources.external.$(sm.var.temp._lang) := $$(filter $$(sm.var.temp._suffix_pat.$(sm.var.temp._lang)),$($(sm._this).sources.external))
  $(sm._this).sources.has.$(sm.var.temp._lang)      := $$(if $$($(sm._this).sources.$(sm.var.temp._lang))$$($(sm._this).sources.external.$(sm.var.temp._lang)),true)

  ## make alias to sm.this.sources.LANGs
  sm.this.sources.$(sm.var.temp._lang) = $$($(sm._this).sources.$(sm.var.temp._lang))
  sm.this.sources.external.$(sm.var.temp._lang) = $$($(sm._this).sources.external.$(sm.var.temp._lang))
  sm.this.sources.has.$(sm.var.temp._lang) = $$($(sm._this).sources.has.$(sm.var.temp._lang))
  )
  endef #sm.fun.compute-sources-for-lang

  define sm.fun.compute-per-source-flags
  $(foreach sm.var.temp._source,\
     $(sm.this.sources.$(sm.var.temp._lang))\
     $(sm.this.sources.external.$(sm.var.temp._lang)),\
    $(eval $(sm._this).compile.flags-$(sm.var.temp._source) := $(sm.this.compile.flags-$(sm.var.temp._source))))
  endef #sm.fun.compute-per-source-flags

  ## sources must always be reset because of possible sm-compile-sources calls
  ## and after sm-use-module, the source list may also be updated
  $(sm._this).sources := $(sm.this.sources)
  $(sm._this).sources.external := $(sm.this.sources.external)
  $(sm._this).sources.common := $(sm.this.sources.common)
  $(sm._this).intermediates := $(sm.this.intermediates)

  ## Compute sources of each language supported by the toolset.
  sm.var.toolset := sm.tool.$($(sm._this).toolset)
  $(foreach sm.var.temp._lang,$($(sm.var.toolset).langs),\
    $(sm.fun.compute-sources-by-lang)\
    $(sm.fun.compute-per-source-flags))

  $(sm._this)._should_compute_sources :=
#endif # $(sm._this)._should_compute_sources == true

#-----------------------------------------------
#-----------------------------------------------

ifneq ($($(sm._this).using_list),)
  define sm.fun.compute-used-flags
  $(eval \
    $(sm._this).used.includes += $($(sm._that).export.includes)
    $(sm._this).used.defines += $($(sm._that).export.defines)
    $(sm._this).used.compile.flags += $($(sm._that).export.compile.flags)
    $(sm._this).used.archive.flags += $($(sm._that).export.archive.flags)
    $(sm._this).used.link.flags += $($(sm._that).export.link.flags)
    $(sm._this).used.libdirs += $($(sm._that).export.libdirs)
    $(sm._this).used.libs += $($(sm._that).export.libs)
   )
  endef #sm.fun.compute-used-flags
  $(foreach sm.var.temp._use,$($(sm._this).using_list),\
    $(info used: $(sm.var.temp._use))\
    $(eval sm._that := sm.var.$(sm.var.temp._use))\
    $(sm.fun.compute-used-flags))
endif # $(sm._this).using_list != ""

ifneq ($($(sm._this).using),)
  $(warning sm.this.using is not working with GNU Make!)

  define sm.fun.using-module
    $(info smart: using $(sm.var.temp._modir))\
    $(if $(filter $(sm.var.temp._modir),$(sm.global.using.loaded)),,\
        $(eval \
          sm.global.using.loaded += $(sm.var.temp._modir)
          sm.var.temp._using := $(wildcard $(sm.var.temp._modir)/smart.mk)
          sm.rules.phony.* += using-$$(sm.var.temp._using)
          goal-$($(sm._this).name) : using-$$(sm.var.temp._using)
          using-$$(sm.var.temp._using): ; \
            $$(info smart: using $$@)\
	    $$(call sm-load-module,$$(sm.var.temp._using))\
            echo using: $$@ -> $$(info $(sm.result.module.name))
         ))
  endef #sm.fun.using-module

  $(foreach sm.var.temp._modir,$($(sm._this).using),$(sm.fun.using-module))
endif # $(sm._this).using != ""

##################################################

sm.var.toolset := sm.tool.$($(sm._this).toolset)
ifeq ($($(sm.var.toolset)),)
  include $(sm.dir.buildsys)/loadtool.mk
endif

ifneq ($($(sm.var.toolset)),true)
  $(error smart: $(sm.var.toolset) is not defined)
endif

ifneq ($($(sm._this).toolset),common)
  ifeq ($($(sm._this).suffix),)
    $(call sm-check-defined,$(sm.var.toolset).target.suffix.$(sm.os.name).$($(sm._this).type))
    $(sm._this).suffix := $($(sm.var.toolset).target.suffix.$(sm.os.name).$($(sm._this).type))
  endif
endif

ifeq ($(strip \
         $($(sm._this).sources)\
         $($(sm._this).sources.external)\
         $($(sm._this).intermediates)),)
  $(error smart: no sources or intermediates for module '$($(sm._this).name)')
endif

ifeq ($($(sm._this).type),t)
 $(if $($(sm._this).lang),,$(error smart: '$(sm._this).lang' must be defined for "tests" module))
endif

sm.args.docs_format := $(strip $($(sm._this).docs.format))
ifeq ($(sm.args.docs_format),)
  sm.args.docs_format := .dvi
endif

##################################################

## Clear compile options for all langs
$(foreach sm.var.temp._lang,$($(sm.var.toolset).langs),\
  $(eval $(sm._this).compile.$($(sm._this)._cnum).flags.$(sm.var.temp._lang) := )\
  $(eval $(sm._this).compile.$($(sm._this)._cnum).flags.$(sm.var.temp._lang).computed := ))

$(sm._this).archive.flags :=
$(sm._this).archive.flags.computed :=
$(sm._this).archive.intermediates =
$(sm._this).archive.intermediates.computed :=
$(sm._this).archive.libs :=
$(sm._this).archive.libs.computed :=
$(sm._this).link.flags :=
$(sm._this).link.flags.computed :=
$(sm._this).link.intermediates =
$(sm._this).link.intermediates.computed :=
$(sm._this).link.libs :=
$(sm._this).link.libs.computed :=

$(sm._this).flag_files :=

##################################################

## make list of only one space separated items
define sm.fun.make-pretty-list
$(strip $(eval sm.var.temp._pretty_list :=)\
  $(foreach _,$1,$(eval sm.var.temp._pretty_list += $(strip $_)))\
  $(sm.var.temp._pretty_list))
endef #sm.fun.make-pretty-list

## eg. $(call sm.fun.append-items,RESULT_VAR_NAME,ITEMS,PREFIX,SUFFIX)
define sm.fun.append-items-with-fix
$(foreach sm.var.temp._item,$(strip $2),\
  $(eval $(strip $1) += $(strip $3)$(sm.var.temp._item:$(strip $3)%$(strip $4)=%)$(strip $4)))
endef #sm.fun.append-items-with-fix

##
## eg. $(call sm.code.shift-flags-to-file,compile,flags.c++)
define sm.code.shift-flags-to-file-r
 ifeq ($(call is-true,$($(sm._this).$1.flags.infile)),true)
  $(sm._this).$1.$2.flat := $$(subst \",\\\",$$($(sm._this).$1.$2))
  $(sm._this).$1.$2 := @$($(sm._this).out.tmp)/$1.$2
  $(sm._this).flag_files += $($(sm._this).out.tmp)/$1.$2
  $($(sm._this).out.tmp)/$1.$2: $($(sm._this).makefile)
	@$$(info smart: flag file: $$@)
	@mkdir -p $($(sm._this).out.tmp)
	@echo $$($(sm._this).$1.$2.flat) > $$@
 endif
endef #sm.code.shift-flags-to-file-r
##
define sm.code.shift-flags-to-file
$$(eval $$(call sm.code.shift-flags-to-file-r,$(strip $1),$(strip $2)))
endef #sm.code.shift-flags-to-file

####################

define sm.fun.compute-flags-compile
$(eval \
  sm.var.temp._fvar_name := $(sm._this).compile.$($(sm._this)._cnum).flags.$(sm.var.temp._lang)
 )\
$(eval \
  ifeq ($($(sm.var.temp._fvar_name).computed),)
    $(sm.var.temp._fvar_name).computed := true
    $(sm.var.temp._fvar_name) := $(call sm.fun.make-pretty-list,\
       $(if $(call equal,$($(sm._this).type),t),-x$($(sm._this).lang))\
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
    $$(call sm.fun.append-items-with-fix,$(sm.var.temp._fvar_name), $(sm.global.includes) $($(sm._this).includes) $($(sm._this).used.includes), -I)
    $(call sm.code.shift-flags-to-file,compile,$($(sm._this)._cnum).flags.$(sm.var.temp._lang))
  endif
 )
endef #sm.fun.compute-flags-compile

##
define sm.fun.compute-flags-archive
$(eval \
  ifeq ($($(sm._this).archive.flags.computed),)
    $(sm._this).archive.flags.computed := true
    $(sm._this).archive.flags := $(call sm.fun.make-pretty-list,\
        $(sm.global.archive.flags)\
        $($(sm._this).used.archive.flags)\
        $($(sm._this).archive.flags))
    $(call sm.code.shift-flags-to-file,archive,flags)
  endif
 )
endef #sm.fun.compute-flags-archive

define sm.fun.compute-flags-link
$(eval \
  ifeq ($($(sm._this).link.flags.computed),)
    $(sm._this).link.flags.computed := true
    $(sm._this).link.flags := $(call sm.fun.make-pretty-list,\
       $($(sm.var.toolset).link.flags)\
       $(sm.global.link.flags)\
       $($(sm._this).used.link.flags)\
       $($(sm._this).link.flags))
    ifeq ($($(sm._this).type),shared)
      $$(if $$(filter -shared,$$($(sm._this).link.flags)),,\
          $$(eval $(sm._this).link.flags += -shared))
    endif
    $(call sm.code.shift-flags-to-file,link,flags)
  endif
 )
endef #sm.fun.compute-flags-link

define sm.fun.compute-intermediates-archive
$(eval \
  ifeq ($($(sm._this).archive.intermediates.computed),)
    $(sm._this).archive.intermediates.computed := true
    $(sm._this).archive.intermediates := $(call sm.fun.make-pretty-list,\
       $($(sm._this).intermediates))
    $(call sm.code.shift-flags-to-file,archive,intermediates)
  endif
 )
endef #sm.fun.compute-intermediates-archive

define sm.fun.compute-libs-archive
$(eval \
  $(sm._this).archive.libs.computed := true
  $(sm._this).archive.libs :=
 )
endef #sm.fun.compute-libs-archive

define sm.fun.compute-intermediates-link
$(eval \
  ifeq ($($(sm._this).link.intermediates.computed),)
    $(sm._this).link.intermediates.computed := true
    $(sm._this).link.intermediates := $(call sm.fun.make-pretty-list,\
       $($(sm._this).intermediates))
    $(call sm.code.shift-flags-to-file,link,intermediates)
  endif
 )
endef #sm.fun.compute-intermediates-link

define sm.fun.compute-libs-link
$(eval \
  ifeq ($($(sm._this).link.libs.computed),)
    $(sm._this).link.libs.computed := true
    $(sm._this).link.libs :=
    $$(call sm.fun.append-items-with-fix, $(sm._this).link.libs, $(sm.global.libdirs) $($(sm._this).libdirs) $($(sm._this).used.libdirs), -L)
    $$(call sm.fun.append-items-with-fix, $(sm._this).link.libs, $(sm.global.libs) $($(sm._this).libs) $($(sm._this).used.libs), -l)
    $(call sm.code.shift-flags-to-file,link,libs)
  endif
 )
endef #sm.fun.compute-libs-link

##################################################

## Compute the intermediate name without suffix.
define sm.fun.compute-intermediate-name
$($(sm._this)._intermediate_prefix)$(basename $(subst ..,_,$(call sm-relative-path,$(sm.var.temp._source))))
endef #sm.fun.compute-intermediate-name

##
##
define sm.fun.compute-intermediate.
$(sm.out.inter)/$(sm.fun.compute-intermediate-name)$(sm.tool.$($(sm._this).toolset).intermediate.suffix.$(sm.var.temp._lang))
endef #sm.fun.compute-intermediate.

define sm.fun.compute-intermediate.external
$(sm.fun.compute-intermediate.)
endef #sm.fun.compute-intermediate.external

define sm.fun.compute-intermediate.common
$(sm.out.inter)/common/$(sm.fun.compute-intermediate-name)$(sm.tool.common.intermediate.suffix.$(sm.var.temp._lang).$($(sm._this).lang))
endef #sm.fun.compute-intermediate.common

##
## source file of relative location
define sm.fun.compute-source.
$(call sm-relative-path,$($(sm._this).dir)/$(strip $1))
endef #sm.fun.compute-source.

##
## source file of fixed location
define sm.fun.compute-source.external
$(call sm-relative-path,$(strip $1))
endef #sm.fun.compute-source.external

##
## binary module to be built
define sm.fun.compute-module-targets-exe
$(call sm-relative-path,$(sm.out.bin))/$($(sm._this).name)$($(sm._this).suffix)
endef #sm.fun.compute-module-targets-exe

define sm.fun.compute-module-targets-t
$(call sm-relative-path,$(sm.out.bin))/$($(sm._this).name)$($(sm._this).suffix)
endef #sm.fun.compute-module-targets-t

define sm.fun.compute-module-targets-shared
$(call sm-relative-path,$(sm.out.bin))/$($(sm._this).name)$($(sm._this).suffix)
endef #sm.fun.compute-module-targets-shared

define sm.fun.compute-module-targets-static
$(call sm-relative-path,$(sm.out.lib))/lib$($(sm._this).name:lib%=%)$($(sm._this).suffix)
endef #sm.fun.compute-module-targets-static

##################################################

ifneq ($(and $(call is-true,$($(sm._this).gen_deps)),\
             $(call not-equal,$(MAKECMDGOALS),clean)),)
define sm.fun.make-rule-depend
  $(eval sm.var.temp._depend := $(sm.var.temp._intermediate:%.o=%$($(sm._this).depend.suffixes)))\
  $(eval \
    -include $(sm.var.temp._depend)
    $(sm._this).depends += $(sm.var.temp._depend)

    ifeq ($(call is-true,$($(sm._this).compile.flags.infile)),true)
      sm.var.temp._flag_file := $($(sm._this).out.tmp)/compile.$($(sm._this)._cnum).flags.$(sm.var.temp._lang)
    else
      sm.var.temp._flag_file :=
    endif

    sm.args.output := $(sm.var.temp._depend)
    sm.args.target := $(sm.var.temp._intermediate)
    sm.args.sources := $(call sm.fun.compute-source.$1,$(sm.var.temp._source))
    sm.args.flags.0 := $($(sm._this).compile.$($(sm._this)._cnum).flags.$(sm.var.temp._lang))
    sm.args.flags.0 += $(strip $($(sm._this).compile.flags-$(sm.var.temp._source)))
    sm.args.flags.1 :=
    sm.args.flags.2 :=
  )$(eval \
   ifeq ($(sm.global.has.rule.$(sm.args.output)),)
    sm.global.has.rule.$(sm.args.output) := true
    $(sm.args.output) : $(sm.var.temp._flag_file) $(sm.args.sources)
	$$(call sm-util-mkdir,$$(@D))
	$(if $(call equal,$($(sm._this).verbose),true),,\
          $$(info smart: update $(sm.args.output))\
          $(sm.var.Q))$(sm.tool.$($(sm._this).toolset).dependency.$(sm.args.lang))
   endif
  )
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
   sm.args.flags.0 := $($(sm._this).compile.$($(sm._this)._cnum).flags.$(sm.var.temp._lang))
   sm.args.flags.0 += $($(sm._this).compile.flags-$(sm.var.temp._source))
   sm.args.flags.1 :=
   sm.args.flags.2 :=

   ifeq ($(call is-true,$($(sm._this).compile.flags.infile)),true)
     $(sm.args.target) : $($(sm._this).out.tmp)/compile.$($(sm._this)._cnum).flags.$(sm.var.temp._lang)
   endif

   $$(sm-rule-compile-$(sm.var.temp._lang))
 )
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
   sm.var.temp._output_lang := $(sm.tool.common.intermediate.lang.$(sm.var.temp._lang).$($(sm._this).lang))
   ## literal output file language, e.g. TeX, LaTeX, etc.
   sm.var.temp._literal_lang := $(sm.tool.common.intermediate.lang.literal.$(sm.var.temp._lang))
  )\
 $(eval sm.var.temp._intermediate := $(sm.fun.compute-intermediate.common))\
 $(if $(and $(call not-equal,$(sm.var.temp._literal_lang),$(sm.var.temp._lang)),
            $(sm.var.temp._output_lang)),$(eval \
   ## args for sm.tool.common.compile.*
   sm.args.lang = $($(sm._this).lang)
   sm.args.target := $(sm.var.temp._intermediate)
   sm.args.sources := $(sm.var.temp._source)
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
        $(sm._this).documents += $(sm.args.target)
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
 ifeq ($$($(sm._this).sources.has.$(sm.var.temp._lang)),true)
  $$(foreach sm.var.temp._source,$$($(sm._this).sources.$(sm.var.temp._lang)),$$(call sm.fun.make-rule-compile))
  $$(foreach sm.var.temp._source,$$($(sm._this).sources.external.$(sm.var.temp._lang)),$$(call sm.fun.make-rule-compile,external))
 endif
 $(null))
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

$(sm._this).targets :=

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
   $(if $(filter $(suffix $(sm.var.temp._source)),$(sm.tool.common.$_.suffix)),\
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
    $$(warning warning: "$(sm.var.temp._source)" is unsupported by toolset "$($(sm._this).toolset)")
    $(sm._this).sources.unknown += $(sm.var.temp._source)
  endif
 )
endef #sm.fun.check-strange-and-compute-common-source

##
##
define sm.fun.make-common-compile-rules-for-langs
$(foreach sm.var.temp._lang,$1,\
   $(if $(sm.tool.common.$(sm.var.temp._lang).suffix),\
      ,$(error smart: toolset $($(sm._this).toolset)/$(sm.var.temp._lang) has no suffixes))\
   $(eval $(sm._this).sources.$(sm.var.temp._lang) = $($(sm._this).sources.$(sm.var.temp._lang)))\
   $(call sm.fun.compute-flags-compile)\
   $(sm.fun.make-rules-compile-common))
endef #sm.fun.make-common-compile-rules-for-langs

##################################################

#-----------------------------------------------
#-----------------------------------------------

## Check strange sources and compute common sources.
sm.var.common.langs :=
sm.var.common.langs.extra :=
$(sm._this).sources.common :=
$(sm._this).sources.unknown :=
$(foreach sm.var.temp._source, $($(sm._this).sources) $($(sm._this).sources.external),\
    $(sm.fun.check-strange-and-compute-common-source))

## Export computed common sources.
$(sm._this).sources.common := $(strip $($(sm._this).sources.common))

## Export computed common sources of different language and make compile rules
## for common sources(files not handled by the toolset, e.g. .w, .nw, etc).
$(call sm.fun.make-common-compile-rules-for-langs,$(sm.var.common.langs))
$(call sm.fun.make-common-compile-rules-for-langs,$(sm.var.common.langs.extra))

## Make compile rules for sources of each lang supported by the selected toolset.
## E.g. $(sm._this).sources.$(sm.var.temp._lang)
$(foreach sm.var.temp._lang,$($(sm.var.toolset).langs),\
  $(if $($(sm.var.toolset).$(sm.var.temp._lang).suffix),\
      ,$(error smart: toolset $($(sm._this).toolset)/$(sm.var.temp._lang) has no suffixes))\
  $(eval $(sm._this).sources.$(sm.var.temp._lang) = $($(sm._this).sources.$(sm.var.temp._lang)))\
  $(call sm.fun.compute-flags-compile)\
  $(sm.fun.make-rules-compile)\
  $(if $(and $(call equal,$(strip $($(sm._this).lang)),),\
             $($(sm._this).sources.has.$(sm.var.temp._lang))),\
         $(info smart: language choosed as "$(sm.var.temp._lang)" for "$($(sm._this).name)")\
         $(eval $(sm._this).lang := $(sm.var.temp._lang))))

## Make object rules for .t sources file
ifeq ($($(sm._this).type),t)
  # set sm.var.temp._lang, used by sm.fun.make-rule-compile
  sm.var.temp._lang := $($(sm._this).lang)

  $(sm._this).sources.$(sm.var.temp._lang).t := $(filter %.t,$($(sm._this).sources))
  $(sm._this).sources.external.$(sm.var.temp._lang).t := $(filter %.t,$($(sm._this).sources.external))
  $(sm._this).sources.has.$(sm.var.temp._lang).t := $(if $($(sm._this).sources.$(sm.var.temp._lang).t)$($(sm._this).sources.external.$(sm.var.temp._lang).t),true)

  ifeq ($(or $($(sm._this).sources.has.$(sm.var.temp._lang)),$($(sm._this).sources.has.$(sm.var.temp._lang).t)),true)
    $(foreach sm.var.temp._source,$($(sm._this).sources.$(sm.var.temp._lang).t),$(call sm.fun.make-rule-compile))
    $(foreach sm.var.temp._source,$($(sm._this).sources.external.$(sm.var.temp._lang).t),$(call sm.fun.make-rule-compile,external))
    ifeq ($($(sm._this).lang),)
      $(sm._this).lang := $($(sm._this).lang)
    endif
  endif

  sm.this.sources.$(sm.var.temp._lang).t = $($(sm._this).sources.$(sm.var.temp._lang).t)
  sm.this.sources.external.$(sm.var.temp._lang).t = $($(sm._this).sources.external.$(sm.var.temp._lang).t)
  sm.this.sources.has.$(sm.var.temp._lang).t = $($(sm._this).sources.has.$(sm.var.temp._lang).t)
endif

sm.var.temp._should_make_targets := \
  $(if $(or $(call not-equal,$(strip $($(sm._this).sources.unknown)),),\
            $(call equal,$(strip $($(sm._this).intermediates)),),\
            $(call is-true,$($(sm._this)._intermediates_only))\
        ),,true)

ifneq ($($(sm._this).toolset),common)
ifeq ($(sm.var.temp._should_make_targets),true)
 ## Make rule for targets of the module
  $(if $($(sm._this).intermediates),,$(error smart: no intermediates for building '$($(sm._this).name)'))

  $(call sm-check-defined,$(sm._this).action)
  $(call sm-check-defined,$(sm._this).lang)
  $(call sm-check-defined,sm-rule-$($(sm._this).action)-$($(sm._this).lang))
  $(call sm-check-defined,sm.fun.compute-flags-$($(sm._this).action))
  $(call sm-check-defined,sm.fun.compute-intermediates-$($(sm._this).action))
  $(call sm-check-defined,sm.fun.compute-libs-$($(sm._this).action))
  $(call sm-check-defined,sm.fun.compute-module-targets-$($(sm._this).type))

  $(call sm-check-defined,sm-rule-$($(sm._this).action)-$($(sm._this).lang))
  $(call sm-check-defined,$(sm._this).$($(sm._this).action).flags)
  $(call sm-check-defined,$(sm._this).$($(sm._this).action).intermediates)
  $(call sm-check-defined,$(sm._this).$($(sm._this).action).libs)
  $(call sm-check-not-empty,$(sm._this).lang)

  $(sm._this).targets := $(strip $(call sm.fun.compute-module-targets-$($(sm._this).type)))

  $(sm.fun.compute-flags-$($(sm._this).action))
  $(sm.fun.compute-intermediates-$($(sm._this).action))
  $(sm.fun.compute-libs-$($(sm._this).action))

  sm.args.target := $($(sm._this).targets)
  sm.args.sources := $($(sm._this).intermediates)
  sm.args.flags.0 := $($(sm._this).$($(sm._this).action).flags)
  sm.args.flags.1 := $($(sm._this).$($(sm._this).action).libs)

  ifeq ($(call is-true,$($(sm._this).$($(sm._this).action).flags.infile)),true)
    sm.var.temp._flag_files := \
       $($(sm._this).out.tmp)/$($(sm._this).action).flags \
       $($(sm._this).out.tmp)/$($(sm._this).action).intermediates

    ifeq ($($(sm._this).action),link)
      sm.var.temp._flag_files += \
       $($(sm._this).out.tmp)/$($(sm._this).action).libs
    endif

    $(warning TODO: apply sm.this.intermediates.infile)

    $(sm.args.target) : $(sm.var.temp._flag_files)
  endif

  $(sm-rule-$($(sm._this).action)-$($(sm._this).lang))

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
sm.this.intermediates = $($(sm._this).intermediates)
sm.this.inters = $(sm.this.intermediates)
sm.this.depends = $($(sm._this).depends)
sm.this.targets = $($(sm._this).targets)
sm.this.documents = $($(sm._this).documents)
sm.this.sources.common = $($(sm._this).sources.common)
sm.this.sources.unknown = $($(sm._this).sources.unknown)

##################################################
##################################################

ifeq ($(sm.var.temp._should_make_targets),true)

ifeq ($(strip $($(sm._this).intermediates)),)
  $(warning smart: no intermediates)
endif

ifeq ($(MAKECMDGOALS),clean)
  goal-$($(sm._this).name) : ; @true
  doc-$($(sm._this).name) : ; @true
else
  goal-$($(sm._this).name) : \
    $($(sm._this).depends) \
    $($(sm._this).depends.copyfiles) \
    $($(sm._this).targets)

  ifneq ($($(sm._this).documents),)
    doc-$($(sm._this).name) : $($(sm._this).documents)
  else
    doc-$($(sm._this).name) : ; @echo smart: No documents for $($(sm._this).name).
  endif
endif

ifeq ($($(sm._this).type),t)
  define sm.code.make-test-rules
    sm.global.tests += test-$($(sm._this).name)
    test-$($(sm._this).name): $($(sm._this).targets)
	@echo test: $($(sm._this).name) - $$< && $$<
  endef #sm.code.make-test-rules
  $(eval $(sm.code.make-test-rules))
endif

$(call sm-check-not-empty, sm.tool.common.rm)
$(call sm-check-not-empty, sm.tool.common.rmdir)

clean-$($(sm._this).name): \
  clean-$($(sm._this).name)-flags \
  clean-$($(sm._this).name)-targets \
  clean-$($(sm._this).name)-intermediates \
  clean-$($(sm._this).name)-depends \
  $($(sm._this).clean-steps)
	@echo "'$(@:clean-%=%)' is cleaned."

define sm.code.clean-rules
sm.rules.phony.* += \
    clean-$($(sm._this).name) \
    clean-$($(sm._this).name)-flags \
    clean-$($(sm._this).name)-targets \
    clean-$($(sm._this).name)-intermediates \
    clean-$($(sm._this).name)-depends \
    $($(sm._this).clean-steps)
clean-$($(sm._this).name)-flags:
	$(if $(call is-true,$($(sm._this).verbose)),,$$(info remove:$($(sm._this).targets))@)$$(call sm.tool.common.rm,$$($(sm._this).flag_files))
clean-$($(sm._this).name)-targets:
	$(if $(call is-true,$($(sm._this).verbose)),,$$(info remove:$($(sm._this).targets))@)$$(call sm.tool.common.rm,$$($(sm._this).targets))
clean-$($(sm._this).name)-intermediates:
	$(if $(call is-true,$($(sm._this).verbose)),,$$(info remove:$($(sm._this).intermediates))@)$$(call sm.tool.common.rm,$$($(sm._this).intermediates))
clean-$($(sm._this).name)-depends:
	$(if $(call is-true,$($(sm._this).verbose)),,$$(info remove:$($(sm._this).depends))@)$$(call sm.tool.common.rm,$$($(sm._this).depends))
endef #sm.code.clean-rules

$(eval $(sm.code.clean-rules))

endif # sm.var.temp._should_make_targets == true

##################################################
##################################################

sm._this.fun :=
sm._this :=

#undefine sm._this.fun
#undefine sm._this
