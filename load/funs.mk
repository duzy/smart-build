#
#
sm.var.target_type.static := static-library
sm.var.target_type.shared := shared-library
sm.var.target_type.exe := executable
sm.var.target_type.t := test
define sm.fun.get-target-type
$(strip $(or $(sm.var.target_type.$($(sm._this).type)),$($(sm._this).type)))
endef #sm.fun.get-target-type

sm.var.command_prompt.compile = $(sm.args.lang): $($(sm._this).name) += $(sm.args.sources:$(sm.top)/%=%)
sm.var.command_prompt.dependency = smart: update $(sm.temp._intermediate_d)..
sm.var.command_prompt.link = $(sm.fun.get-target-type): $($(sm._this).name) -> $(sm.args.target)

######################################################################

define sm.fun.using-module
  ${warning "sm.this.using" is not working with GNU Make!}\
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
define sm.fun.using
$(eval \
  ifdef $(sm._this).using
    $${warning "sm.this.using" is not working with GNU Make!}
    $${foreach sm.var.temp._modir,$($(sm._this).using),$$(sm.fun.using-module)}
  endif # $(sm._this).using != ""
 )
endef #sm.fun.using

## <!!!>
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

## <!!!>
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

## (bool,var,what)
define sm.fun.shift-flags-to-file
$(strip $(eval #
  sm.temp._flagsvar := $(strip $1)
  sm.temp._what  := $(strip $2)
  sm.temp._shift := $(call true,$(strip $3))
 )\
$(eval #
  sm.temp._flag_file :=
  ifeq ($(sm.temp._shift),true)
    sm.temp._flag_file := $($(sm._this).out.tmp)/flags.$(sm.temp._what).$($(sm._this)._cnum)
    sm.temp._flat_flags := $(subst \",\\\",$($(sm.temp._flagsvar)))
  endif
 )\
$(if $(sm.temp._flag_file),\
  $(eval #
    $(sm.temp._flag_file) : $($(sm._this).makefile)
	$$(info smart: flags: $$@)\
	mkdir -p $$(@D) && echo "$(sm.temp._flat_flags)" > $$@
   )\
 )\
$(sm.temp._flag_file))
endef #sm.fun.shift-flags-to-file

## <!!!>
define sm.fun.compute-compile-flags
${eval \
  sm.temp._fvar_prop := compile.flags.$($(sm._this)._cnum).$(sm.var.source.lang)
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
       $($(sm.var.tool).defines.$(sm.source.var.lang))\
       $($(sm.var.tool).compile.flags)\
       $($(sm.var.tool).compile.flags.$(sm.source.var.lang))\
       $(sm.global.defines)\
       $(sm.global.defines.$(sm.var.source.lang))\
       $(sm.global.compile.flags)\
       $(sm.global.compile.flags.$(sm.var.source.lang))\
       $($(sm._this).used.defines)\
       $($(sm._this).used.defines.$(sm.var.source.lang))\
       $($(sm._this).used.compile.flags)\
       $($(sm._this).used.compile.flags.$(sm.var.source.lang))\
       $($(sm._this).defines)\
       $($(sm._this).defines.$(sm.var.source.lang))\
       $($(sm._this).compile.flags)\
       $($(sm._this).compile.flags.$(sm.var.source.lang)))

    $$(call sm.fun.append-items-with-fix, $(sm.var.temp._fvar_name), \
           $$($(sm._this).includes) \
           $$($(sm._this).used.includes)\
           $($(sm.var.tool).includes)\
           $$(sm.global.includes) \
          , -I, , -%)

    $$(call sm-remove-duplicates,$(sm.var.temp._fvar_name))

    ifeq ($(call true,$($(sm._this).compile.flags.infile)),true)
      $(call sm.code.shift-flags-to-file,$(sm.temp._fvar_prop))
    endif
  endif
 }
endef #sm.fun.compute-compile-flags

## <!!!>
define sm.fun.compute-link-flags
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

    $$(call sm-remove-duplicates,$(sm._this)._link.flags)

    ifeq ($(call true,$($(sm._this).link.flags.infile)),true)
      $(call sm.code.shift-flags-to-file,_link.flags)
    endif
  endif
 }
endef #sm.fun.compute-link-flags

## <!!!>
define sm.fun.compute-link-intermediates
$(eval \
  sm.temp._intermediates_filters := $(foreach _,$($(sm.var.tool).langs),%$($(sm.var.tool).suffix.intermediate.$_))
  ifndef sm.temp._intermediates_filters
    sm.temp._intermediates_filters := %
  else
    $$(call sm-remove-duplicates, sm.temp._intermediates_filters)
  endif
 )\
$(eval \
  ifeq ($($(sm._this)._link.intermediates.computed),)
    $(sm._this)._link.intermediates.computed := true
    $(sm._this)._link.intermediates := $(filter $(sm.temp._intermediates_filters), $($(sm._this).intermediates))

    ifeq ($(call true,$($(sm._this).link.intermediates.infile)),true)
      $(call sm.code.shift-flags-to-file,_link.intermediates)
    endif
  endif
 )
endef #sm.fun.compute-link-intermediates

## <!!!>
define sm.fun.compute-link-libs
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

    $$(call sm-remove-duplicates,$(sm._this)._link.libdirs)

    $$(call sm.fun.append-items-with-fix, $(sm._this)._link.libs, \
           $$(sm.global.libs) \
           $$($(sm._this).libs) \
           $$($(sm._this).used.libs)\
        , -l, , -% -Wl% %.a %.so %.lib %.dll)

    $$(call sm-remove-sequence-duplicates,$(sm._this)._link.libs)

    $(sm._this)._link.libs := \
       $$($(sm._this)._link.libdirs) \
       $$($(sm._this)._link.libs)

    ifeq ($(call true,$($(sm._this).libs.infile)),true)
      $(call sm.code.shift-flags-to-file,_link.libs)
    endif
  endif
 }
endef #sm.fun.compute-link-libs

##################################################

## <!!!>
## binary module to be built
define sm.fun.compute-module-targets-exe
$(patsubst $(sm.top)/%,%,$(sm.out.bin))/$($(sm._this).name)$($(sm._this).suffix)
endef #sm.fun.compute-module-targets-exe

## <!!!>
define sm.fun.compute-module-targets-t
$(patsubst $(sm.top)/%,%,$(sm.out.bin))/$($(sm._this).name)$($(sm._this).suffix)
endef #sm.fun.compute-module-targets-t

## <!!!>
define sm.fun.compute-module-targets-shared
$(patsubst $(sm.top)/%,%,$(sm.out.bin))/$($(sm._this).name)$($(sm._this).suffix)
endef #sm.fun.compute-module-targets-shared

## <!!!>
define sm.fun.compute-module-targets-static
$(patsubst $(sm.top)/%,%,$(sm.out.lib))/lib$($(sm._this).name:lib%=%)$($(sm._this).suffix)
endef #sm.fun.compute-module-targets-static

##################################################

##
define sm.fun.make-rules-targets
$(call sm-check-not-empty,\
    sm._this $(sm._this).name sm.var.tool \
 )\
$(eval \
  $(sm._this).targets :=
 )\
$(call $(sm.var.tool).transform-intermediates)
endef #sm.fun.make-rules-targets

##################################################

## <!!!>
## copy headers according to sm.this.headers.PREFIX
define sm.fun.make-rules-headers-of-prefix
$(eval \
    ifneq ($(call true,$($(sm._this).headers.$(sm.var.temp._hp)!)),true)
    ifneq ($($(sm._this).headers.$(sm.var.temp._hp)),)
      $$(call sm-copy-files, $($(sm._this).headers.$(sm.var.temp._hp)), $(sm.out.inc)/$(sm.var.temp._hp))
    endif # $(sm._this).headers.$(sm.var.temp._hp)! != true
    endif # $(sm._this).headers.$(sm.var.temp._hp) != ""
 )
endef #sm.fun.make-rules-headers-of-prefix

## <!!!>
## copy headers according to all sm.this.headers.XXX variables
define sm.fun.make-rules-headers
$(eval \
  ## sm-copy-files will append items to sm.this.depends.copy
  sm.this.depends.copy_saved := $(sm.this.depends.copy)
  sm.this.depends.copy :=
 )\
$(eval \
  ## headers from sm.this.headers
  ifneq ($(call true,$($(sm._this).headers!)),true)
    ifdef $(sm._this).headers
      $$(call sm-copy-files, $($(sm._this).headers), $(sm.out.inc))
    endif # $(sm._this).headers != ""
  endif # $(sm._this).headers! == true

  ifdef sm.var._headers_vars
    $$(foreach sm.var.temp._hp, $(sm.var._headers_vars:$(sm._this).headers.%=%),\
        $$(sm.fun.make-rules-headers-of-prefix))
  endif # $(sm._this).headers.* != ""

  ## export the final copy rule
  $(sm._this).depends.copy += $$(sm.this.depends.copy)

  ## this allow consequenced rules
  headers-$($(sm._this).name) : $$(sm.this.depends.copy)
 )\
$(eval \
  ## must restore sm.this.depends.copy
  sm.this.depends.copy := $(sm.this.depends.copy_saved)
  sm.this.depends.copy_saved :=
 )
endef #sm.fun.make-rules-headers

## <!!!>
##
define sm.fun.make-rules-test
$(if $(call equal,$($(sm._this).type),t), $(eval \
  sm.global.tests += test-$($(sm._this).name)
  test-$($(sm._this).name): $($(sm._this).targets)
	@echo test: $($(sm._this).name) - $$< && $$<
 ))
endef #sm.fun.make-rules-test

## <!!!>
define sm.fun.make-rules-clean
$(if $(call equal,$($(sm._this).type),depends), $(eval \
    clean-$($(sm._this).name):
	rm -vf $$($(sm._this).depends) $$($(sm._this).depends.copy)
  )\
 ,$(eval \
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

  ifeq ($(call true,$($(sm._this).verbose)),true)
    clean-$($(sm._this).name)-flags:
	rm -f $$($(sm._this).flag_files)
    clean-$($(sm._this).name)-targets:
	rm -f $$($(sm._this).targets)
    clean-$($(sm._this).name)-intermediates:
	rm -f $$($(sm._this).intermediates)
    clean-$($(sm._this).name)-depends:
	rm -f $$($(sm._this).depends)
  else
    clean-$($(sm._this).name)-flags:
	@$$(info remove:$($(sm._this).targets))(rm -f $$($(sm._this).flag_files))
    clean-$($(sm._this).name)-targets:
	@$$(info remove:$($(sm._this).targets))(rm -f $$($(sm._this).targets))
    clean-$($(sm._this).name)-intermediates:
	@$$(info remove:$($(sm._this).intermediates))(rm -f $$($(sm._this).intermediates))
    clean-$($(sm._this).name)-depends:
	@$$(info remove:$($(sm._this).depends))(rm -f $$($(sm._this).depends))
  endif
  )\
 )
endef #sm.fun.make-rules-clean

## <!!!>
##
define sm.fun.invoke-toolset-built-target-mk
$(eval \
  ifeq ($(sm.var.temp._should_make_targets),true)
    sm.var.temp._built_mk := $(sm.dir.buildsys)/tools/$($(sm._this).toolset)/built-target.mk
    sm.var.temp._built_mk := $$(wildcard $$(sm.var.temp._built_mk))
    ifdef sm.var.temp._built_mk
      include $(sm.var.temp._built_mk)
    endif #sm.var.temp._built_mk
  endif # sm.var.temp._should_make_targets == true
 )
endef #sm.fun.invoke-toolset-built-target-mk

######################################################################
## new build rules...
######################################################################

## <NEW>
## 
define sm.fun.init-toolset
$(eval \
  ifeq ($($(sm.var.tool)),)
    include $(sm.dir.buildsys)/loadtool.mk
  endif

  ifneq ($($(sm.var.tool)),true)
    $$(error smart: $(sm.var.tool) is not defined)
  endif

  $(foreach sm.var.lang, $($(sm.var.tool).langs),
    $(foreach _, $($(sm.var.tool).suffix.$(sm.var.lang)),
      sm.var.lang$_ := $(sm.var.lang)
     )
   )

  sm.var.lang :=
 )
endef #sm.fun.init-toolset

## <NEW>
## 
define sm.fun.compute-using-list
$(if $($(sm._this).using_list), $(eval \
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
  ${foreach sm.var._use, $($(sm._this).using_list),
    sm._that := sm.module.$(sm.var._use)
    include $(sm.dir.buildsys)/funs/use.mk
   }
 ))
endef #sm.fun.compute-using-list

## <NEW>
##
define sm.fun.compute-terminated-intermediates
$(eval \
  sm.var.source_variables := $(filter $(sm._this).sources%, $(.VARIABLES))
  sm.var.source_types :=
 )\
$(foreach sm.var.source_var, $(sm.var.source_variables),\
  $(eval \
    sm.var.source_type := $(sm.var.source_var:$(sm._this).sources%=%)
    ifndef sm.var.source_type
      sm.var.source_type := .local
    endif

    sm.var.source_types += $$(sm.var.source_type:.%=%)

    ## Compute sources of each language supported by the toolset.
    $(sm._this).unterminated$$(sm.var.source_type) := $$($(sm.var.source_var))
   )\
 )\
$(eval \
  sm.any-unterminated-sources = $$(or $(foreach _,$(sm.var.source_types),$$($(sm._this).unterminated.$_),))

  ## Reduce the unterminated list to produce terminated intermediates.
  include $(sm.dir.buildsys)/funs/reduce.mk

  sm.any-unterminated-sources :=
  ## All unterminated intermediates are expected to be reduced at this point!
 )\
$(call sm-check-empty, \
    $(sm._this).unterminated.external \
    $(sm._this).unterminated \
 )
endef #sm.fun.compute-terminated-intermediates

## <NEW>
## 
## Handle with the input "sm.var.sources", compute the terminated intermediates.
##
## INPUT:
##     *) sm.var.sources: module local sources
##     *) sm.var.sources.external: module external sources
## OUTPUT:
##     *) $(sm._this).intermediates (append to it)
## 
define sm.fun.make-rules-intermediates
$(eval \
  sm.var.source_vars := $(filter sm.var.sources.%, $(.VARIABLES))
 )\
$(foreach sm.var.source_var, $(sm.var.source_vars),\
  $(eval \
    sm.var.source.type := $(sm.var.source_var:sm.var.sources.%=%)
   )\
  $(foreach sm.var.source, $(sm.var.sources.$(sm.var.source.type)),\
       $(sm.fun.make-intermediate-rule))\
  $(eval \
    sm.var.source.type :=
   )\
 )
endef #sm.fun.make-rules-intermediates

## <NEW>
##
## Make intermedate rule for one single source, append terminated intermediate
## to $(sm._this).intermediates.
##
## INPUT:
##     *) sm.var.source:
##     *) sm.var.lang.XXX: where XXX is $(suffix $(sm.var.source))
## OUTPUT:
##     *) $(sm._this).intermediates
##     *) sm.var.source.suffix
##     *) sm.var.source.lang
##
define sm.fun.make-intermediate-rule
$(call sm-check-not-empty, \
    sm.var.tool \
    sm.var.source \
    sm.var.source.type \
 , no source or unknown source type or toolset \
 )\
$(eval \
  sm.var.source.suffix := $(suffix $(sm.var.source))
  sm.var.source.lang := $$(sm.var.lang$$(sm.var.source.suffix))
  sm.var.source.where := $(or $(filter $(sm.var.source.type),local external),local)
  sm.var.source.computed := $$(call sm.fun.compute-source-of-$$(sm.var.source.where))
  sm.var.intermediate := $$(sm.fun.compute-intermediates-of-$$(sm.var.source.where))

  ## Use a foreach on $(sm.var.tool).langs to keep the orders
  $(sm._this).langs := $$(foreach _, $($(sm.var.tool).langs),$$(filter $$_,$$(sm.var.source.lang) $($(sm._this).langs))) $($(sm._this).langs)
  $$(call sm-remove-duplicates, $(sm._this).langs)
  $(sm._this).lang := $$(firstword $$($(sm._this).langs))
 )\
$(call sm-check-not-empty, \
    sm.var.intermediate \
 , source "$(sm.var.source)" is strange (type: "$(sm.var.source.type)", lang: "$(sm.var.source.lang)"))\
$(call $(sm.var.tool).transform-single-source)
endef #sm.fun.make-intermediate-rule

## <NEW>
##
## ARGUMENTS:
##   1) the prompt text for non-verbose build
##   2) the original shell commands
## RETURN:
##   *) 
define sm.fun.wrap-rule-commands
$(strip $(eval \
  sm.temp._command_prompt := $(strip $1)
  sm.temp._command_text := $(filter %,$2)
 )\
$(if $(call true,$($(sm._this).verbose)),\
    $(sm.temp._command_text) \
 ,\
    $(sm.temp._command_text) \
 ))
endef #sm.fun.wrap-rule-commands

## <NEW>
##
## RETURN:
##   *) "ok" on success
define sm.fun.compute-intermediates-of-local
$(strip \
  $(eval sm.temp._inter_name := $(basename $(sm.var.source)))\
  $(eval sm.temp._inter_name := $(sm.temp._inter_name:$(sm.out.inter)/%=%))\
  $(eval sm.temp._inter_name := $(sm.temp._inter_name:$($(sm._this).prefix)%=%))\
  $(eval sm.temp._inter_name := $(sm.temp._inter_name:$(sm.top)/%=%))\
  $(eval sm.temp._inter_name := $(subst ..,_,$(sm.temp._inter_name)))\
  $(eval sm.temp._inter_name := $($(sm._this).prefix)$(sm.temp._inter_name))\
  $(call sm.fun.compute-intermediates))
endef #sm.fun.compute-intermediates-of-local

## <NEW>
##
## RETURN:
##   *) "ok" on success
define sm.fun.compute-intermediates-of-external
$(strip \
  $(eval sm.temp._inter_name := $(basename $(sm.var.source)))\
  $(eval sm.temp._inter_name := $(sm.temp._inter_name:$(sm.out.inter)/%=%))\
  $(eval sm.temp._inter_name := $(sm.temp._inter_name:$($(sm._this).dir)%=%))\
  $(eval sm.temp._inter_name := $(sm.temp._inter_name:$($(sm._this).prefix)%=%))\
  $(eval sm.temp._inter_name := $(sm.temp._inter_name:$($(sm._this).name)%=%))\
  $(eval sm.temp._inter_name := $(sm.temp._inter_name:$(sm.top)/%=%))\
  $(eval sm.temp._inter_name := $(subst ..,_,$(sm.temp._inter_name)))\
  $(eval sm.temp._inter_name := $($(sm._this).prefix)$(sm.temp._inter_name))\
  $(call sm.fun.compute-intermediates))
endef #sm.fun.compute-intermediates-of-external

## <NEW>
##
## RETURN:
##   *) the local source file path related to $(sm.top)
define sm.fun.compute-source-of-local
$(strip \
  $(eval sm.temp._source := $(sm.var.source))\
  $(eval sm.temp._source := $($(sm._this).dir)/$(sm.temp._source))\
  $(eval sm.temp._source := $(sm.temp._source:$(sm.top)/%=%))\
  $(sm.temp._source))
endef #sm.fun.compute-source-of-local

## <NEW>
##
## RETURN:
##   *) the external source file path, may be related to $(sm.top)
define sm.fun.compute-source-of-external
$(strip \
  $(eval sm.temp._source := $(sm.var.source))\
  $(eval sm.temp._source := $(sm.temp._source:$(sm.top)/%=%))\
  $(sm.temp._source))
endef #sm.fun.compute-source-of-external

## <NEW>
##
## INPUT:
##   *) sm.var.tool
##   *) sm.var.source.lang
##   *) sm.temp._inter_name
## RETURN:
##   *) list of intermediates
define sm.fun.compute-intermediates
$(strip \
  $(call sm-check-not-empty, \
     sm.temp._inter_name \
   , unknown intermediate name)\
  $(eval \
    sm.temp._inter_suff :=

    ifdef sm.var.source.lang
      sm.temp._inter_suff := $($(sm.var.tool).suffix.intermediate.$(sm.var.source.lang))

      ifndef sm.temp._inter_suff
        $$(info smart:0: no intermediate suffix for language '$(sm.var.source.lang) -> $_' defined by toolset '$(sm.var.tool:sm.tool.%=%)')
      else
        ## combined with the source suffix to avoid conflicts like
        ## foo.go, foo.c, foo.cpp, they both have ".o" suffix
        sm.temp._inter_suff := $(suffix $(sm.var.source))$$(sm.temp._inter_suff)
      endif
    endif
   )\
  $(subst //,/,$(sm.out.inter)/$($(sm._this).name)/$(sm.temp._inter_name)$(sm.temp._inter_suff))\
 )
endef #sm.fun.compute-intermediates

## <NEW>
##
## INPUT:
##   *) sm.var.tool
##   *) sm.var.source.lang
## RETURN:
##   *) the toolset defined intermediate suffix
define sm.fun.compute-intermediates-langs
$(strip \
  $(call sm-check-not-empty, \
      sm.var.tool \
      sm.var.source.lang \
   , unknown toolset or source file language \
   )\
  $(eval \
    sm.temp._inter_langs :=

    ## check if the source lang can be converted into other source of language
    ifdef $(sm.var.tool).langs.intermediate.$(sm.var.source.lang)
      sm.temp._inter_langs := $(filter $($(sm._this).langs),$($(sm.var.tool).langs.intermediate.$(sm.var.source.lang)))
      ifndef sm.temp._inter_langs
        $$(info smart:0: toolset '$(sm.var.tool:sm.tool.%=%)' can convert '$(sm.var.source.lang)' to one of '$($(sm.var.tool).langs.intermediate.$(sm.var.source.lang))',)
        $$(info smart:0: but none of these languages are selected (via 'sm.this.langs'))
        $$(error no target language selected for '$(sm.var.source.lang)' ($(sm.var.source)))
      endif
    endif
   )\
 )
endef #sm.fun.compute-intermediates-langs

## <NEW>
##
## INPUT:
##   *) sm.var.source
##   *) sm.temp._intermediates
## RETURN:
##   *) 
define sm.fun.draw-intermediate-dependency
$(call sm-check-not-empty, \
    sm.args.lang \
    sm.temp._intermediate \
 )\
$(eval sm.temp._intermediate_d := $(sm.temp._intermediate).d)\
$(eval \
  -include $(sm.temp._intermediate_d)

  ifeq ($(call true,$($(sm._this).compile.flags.infile)),true)
    sm.temp._flag_file := $($(sm._this).out.tmp)/compile.flags.$($(sm._this)._cnum).$(sm.var.source.lang)
  else
    sm.temp._flag_file :=
  endif

  sm.args.action.saved := $(sm.args.action)
  sm.args.action := dependency

  sm.args.output := $(sm.temp._intermediate_d)
  sm.args.target := $(sm.temp._intermediate)
  sm.args.sources := $(call sm.fun.compute-source-of-$(sm.var.source.type))
  sm.args.flags.0 := $($(sm._this).compile.flags.$($(sm._this)._cnum).$(sm.var.source.lang))
  sm.args.flags.0 += $(strip $($(sm._this).compile.flags-$(sm.var.source)))
  sm.args.flags.1 :=
  sm.args.flags.2 :=
 )\
$(if $($(sm.var.tool).$(sm.args.action).$(sm.args.lang)),\
  $(no-info DEP: $(sm.var.tool).$(sm.args.action).$(sm.args.lang) for $(sm.args.output))\
  $(eval \
    ifeq ($(sm.global.ruled.$(sm.args.output)),)
      sm.global.ruled.$(sm.args.output) := true

      ifeq ($(wildcard $(sm.args.sources)),)
        #$$(info smart: missing $(sm.args.sources) ($($(sm._this).name)))
      endif

      $(sm.args.output) : $(sm.temp._flag_file) $(sm.args.sources)
	@[[ -d $$(@D) ]] || mkdir -p $$(@D)
	$(call sm.fun.wrap-rule-commands,\
	    $(sm.var.command_prompt.$(sm.args.action)),\
	    $($(sm.var.tool).$(sm.args.action).$(sm.args.lang)))
    endif
   )\
 , $(no-info TODO: $(sm.var.tool).$(sm.args.action).$(sm.args.lang) for $(sm.args.output))\
 )\
$(eval \
  sm.args.action := $(sm.args.action.saved)
  sm.args.action.saved :=
 )
endef #sm.fun.draw-intermediate-dependency
