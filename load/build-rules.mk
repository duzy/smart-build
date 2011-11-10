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

ifndef sm._this
  $(error sm._this is empty)
endif # sm._this == ""

$(call sm-check-not-empty,	\
    $(sm._this).dir		\
    $(sm._this).name		\
    $(sm._this).type		\
 )

##################################################

## configure the module if not yet done
$(sm._this)._configured := true
$(sm._this).out.tmp := $(sm.out.tmp)/$($(sm._this).name)
$(sm._this).user_defined_targets := $($(sm._this).targets)
$(sm._this).targets :=

## get toolset name
sm.var.tool := sm.tool.$($(sm._this).toolset)
sm.var.langs := $($(sm.var.tool).langs)

sm.var.temp._ := $($(sm._this).dir:$(sm.top)%=%)
sm.var.temp._ := $(sm.var.temp._:%.=%)
sm.var.temp._ := $(sm.var.temp._:/%=%)
sm.var.temp._ := ${if $(sm.var.temp._),$(sm.var.temp._)/}
$(sm._this)._intermediate_prefix := $(sm.var.temp._)

## Compute sources of each language supported by the toolset.
${foreach sm.var.lang, $(sm.var.langs),$(sm.fun.compute-sources-by-lang)}

#-----------------------------------------------
#-----------------------------------------------
ifdef $(sm._this).using_list
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

ifdef $(sm._this).using
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
  ifeq ($($(sm.var.tool)),)
    include $(sm.dir.buildsys)/loadtool.mk
  endif

  ifneq ($($(sm.var.tool)),true)
    $(error smart: $(sm.var.tool) is not defined)
  endif

  ifneq ($($(sm._this).toolset),common)
    ifndef $(sm._this).suffix
      ${call sm-check-defined,$(sm.var.tool).suffix.target.$($(sm._this).type).$(sm.os.name)}
      $(sm._this).suffix := $($(sm.var.tool).suffix.target.$($(sm._this).type).$(sm.os.name))
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
ifndef sm.args.docs_format
  sm.args.docs_format := .dvi
endif

##################################################

## Clear compile options for all langs
ifneq ($(strip $($(sm._this).type)),depends)
${foreach sm.var.lang,$(sm.var.langs),\
  ${eval $(sm._this).compile.flags.$($(sm._this)._cnum).$(sm.var.lang) := }\
  ${eval $(sm._this).compile.flags.$($(sm._this)._cnum).$(sm.var.lang).computed := }}
endif ## $(sm._this).type != depends

$(sm._this)._link.flags :=
$(sm._this)._link.flags.computed :=
$(sm._this)._link.intermediates =
$(sm._this)._link.intermediates.computed :=
$(sm._this)._link.libs :=
$(sm._this)._link.libs.computed :=

$(sm._this).flag_files :=

##################################################

#-----------------------------------------------
#-----------------------------------------------

## Check strange sources and compute common sources.
sm.var.common.langs :=
sm.var.common.langs.extra :=
$(sm._this).sources.common :=
$(sm._this).sources.unknown :=
ifneq ($(strip $($(sm._this).type)),depends)
  $(foreach sm.var.source, $($(sm._this).sources) $($(sm._this).sources.external),\
      $(sm.fun.check-strange-and-compute-common-source))
endif ## $(sm._this).type != depends

## Export computed common sources.
$(sm._this).sources.common := $(strip $($(sm._this).sources.common))

## Export computed common sources of different language and make compile rules
## for common sources(files not handled by the toolset, e.g. .w, .nw, etc).
$(call sm.fun.make-common-compile-rules-for-langs,\
    $(sm.var.common.langs) \
    $(sm.var.common.langs.extra) \
 )

ifneq ($($(sm._this).type),depends)
  $(call sm.fun.make-compile-rules-for-langs)
endif ## $(sm._this).type != depends

ifeq ($($(sm._this).type),t)
  $(call sm.fun.make-t-compile-rules-for-langs)
endif # $(sm._this).type == t

sm.var.temp._should_make_targets := \
  $(if $(or $(call not-equal,$(strip $($(sm._this).sources.unknown)),),\
            $(call equal,$(strip $($(sm._this).type)),depends),\
            $(call equal,$(strip $($(sm._this).intermediates)),),\
            $(call is-true,$($(sm._this)._intermediates_only)))\
        ,,true)

##-----------------------------------
## make module targets
ifneq ($($(sm._this).toolset),common)
  ifeq ($(sm.var.temp._should_make_targets),true)
    $(call sm.fun.make-module-targets)
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
  $(foreach sm.var.temp._hp, $($(sm._this).headers.*), $(sm.fun.copy-headers))
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
    $(sm.fun.make-test-rules)
  endif ## $($(sm._this).type) == t

  $(sm.fun.make-clean-rules)

  sm.var.temp._built_mk := $(sm.dir.buildsys)/tools/$($(sm._this).toolset)/built-target.mk
  sm.var.temp._built_mk := $(wildcard $(sm.var.temp._built_mk))
  ifdef sm.var.temp._built_mk
    include $(sm.var.temp._built_mk)
  endif #sm.var.temp._built_mk
else
  ifeq ($(strip $($(sm._this).type)),depends)
    goal-$($(sm._this).name): \
      $($(sm._this).depends) \
      $($(sm._this).depends.copyfiles) \
      $($(sm._this).targets) #; @echo "smart: $@, $^"
    clean-$($(sm._this).name):
	$(call sm.tool.common.rm, $($(sm._this).depends) $($(sm._this).depends.copyfiles))
    $(eval doc-$($(sm._this).name) : ; @echo "smart: No documents for $($(sm._this).name).")
  endif ## $(sm._this).type != depends
endif # sm.var.temp._should_make_targets == true

##################################################
##################################################
