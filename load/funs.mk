#
#
######################################################################

##
##
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

##
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
## (var,what,bool)
define sm.fun.shift-flags-to-file
$(strip $(eval #
  sm.temp._flagsvar := $(strip $1)
  sm.temp._what  := $(strip $2)
  sm.temp._shift := $(call sm-true,$(strip $3))
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

##
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

##
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

##
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

  $$(call sm-check-empty, sm.any-unterminated-sources)

  sm.any-unterminated-sources :=
  ## All unterminated intermediates are expected to be reduced at this point!
 )
endef #sm.fun.compute-terminated-intermediates

##
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

    ## must clear the sources
    $(sm.var.source_var) :=
   )\
 )
endef #sm.fun.make-rules-intermediates

##
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

##
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
$(if $(call sm-true,$($(sm._this).verbose)),\
    $(sm.temp._command_text) \
 ,\
    $(sm.temp._command_text) \
 ))
endef #sm.fun.wrap-rule-commands

##
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

##
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

##
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

##
##
## RETURN:
##   *) the external source file path, may be related to $(sm.top)
define sm.fun.compute-source-of-external
$(strip \
  $(eval sm.temp._source := $(sm.var.source))\
  $(eval sm.temp._source := $(sm.temp._source:$(sm.top)/%=%))\
  $(sm.temp._source))
endef #sm.fun.compute-source-of-external

##
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

##
##
define sm.fun.invoke-toolset-built-target-mk
$(eval \
  #ifeq ($(sm.var.temp._should_make_targets),true)
    sm.var.temp._built_mk := $(sm.dir.buildsys)/tools/$($(sm._this).toolset)/built-target.mk
    sm.var.temp._built_mk := $$(wildcard $$(sm.var.temp._built_mk))
    ifdef sm.var.temp._built_mk
      include $$(sm.var.temp._built_mk)
    endif #sm.var.temp._built_mk
  #endif # sm.var.temp._should_make_targets == true
 )
endef #sm.fun.invoke-toolset-built-target-mk

##################################################

##
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

##
## copy headers according to sm.this.headers.PREFIX
define sm.fun.make-rules-headers-of-prefix
$(eval \
    ifneq ($(call sm-true,$($(sm._this).headers.$(sm.var.temp._hp)!)),true)
    ifneq ($($(sm._this).headers.$(sm.var.temp._hp)),)
      $$(call sm-copy-files, $($(sm._this).headers.$(sm.var.temp._hp)), $(sm.out.inc)/$(sm.var.temp._hp))
    endif # $(sm._this).headers.$(sm.var.temp._hp)! != true
    endif # $(sm._this).headers.$(sm.var.temp._hp) != ""
 )
endef #sm.fun.make-rules-headers-of-prefix

##
## copy headers according to all sm.this.headers.XXX variables
define sm.fun.make-rules-headers
$(eval \
  ## sm-copy-files will append items to sm.this.depends.copy
  sm.this.depends.copy_saved := $(sm.this.depends.copy)
  sm.this.depends.copy :=
 )\
$(eval \
  ## headers from sm.this.headers
  ifneq ($(call sm-true,$($(sm._this).headers!)),true)
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

##
##
define sm.fun.make-rules-test
$(if $(call equal,$($(sm._this).type),t), $(eval \
  sm.global.tests += test-$($(sm._this).name)
  test-$($(sm._this).name): $($(sm._this).targets)
	@echo test: $($(sm._this).name) - $$< && $$<
 ))
endef #sm.fun.make-rules-test

##
##
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

  ifeq ($(call sm-true,$($(sm._this).verbose)),true)
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
