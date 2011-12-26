#
# reduce.mk - reduce the $(sm._this).unterminated list until it's empty and
#             producing output into $(sm._this).intermediates, making
#             intermediates generation rules.
#
$(call sm-check-not-empty, sm._this)

#$(info any: $(sm.any-unterminated-sources))

ifneq ($(strip $(sm.any-unterminated-sources)),)
  $(sm._this).reduce_level := $($(sm._this).reduce_level)x

  ## Store unterminated intermediates into sm.var.sources.* for make intermediates
  ## rules. And immediately reset the unterminated list.
  $(foreach _, $(filter $(sm._this).unterminated%, $(.VARIABLES)),\
   $(if $(findstring .strangeX,$_X),,\
       $(eval sm.temp._ := $(_:$(sm._this).unterminated%=%))\
       $(eval sm.var.sources$(sm.temp._) := $($_))\
       $(eval sm.temp._ :=)\
       $(eval $_ :=)\
    )\
  )

  ## Call the make-intermediates-rules function to reduce $(sm.var.sources) for
  ## terminated intermediates generation rules.
  $(call sm-check-flavor, sm.fun.make-rules-intermediates, recursive)
  $(call sm.fun.make-rules-intermediates)

  #$(info $(sm._this).unterminated: $($(sm._this).reduce_level): $($(sm._this).unterminated))

  ifdef $(sm._this).unterminated.strange
    ## Does nothing in this case except that the unterminated list should be
    ## cleared.
    $(foreach _, $(filter $(sm._this).unterminated%, $(.VARIABLES)),\
       $(if $(findstring .strangeX,$_X),,$(eval $_ :=)))
  else
    ## must set sm.any-unterminated-sources
    $(eval sm.any-unterminated-sources = $$(or $(foreach _,$(filter $(sm._this).unterminated%,$(.VARIABLES)),$$($_),)))

    ## Go on if unterminated intermediates reproduced.
    ifneq ($(strip $(sm.any-unterminated-sources)),)
      include $(sm.dir.buildsys)/funs/reduce.mk
    endif #$(sm._this).unterminated != <EMPTY>
  endif # $(sm._this).unterminated.strange != <EMPTY>
endif #$(sm._this).unterminated != <EMPTY>
