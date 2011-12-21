#
# reduce.mk - reduce the $(sm._this).unterminated list until it's empty and
#             producing output into $(sm._this).intermediates, making
#             intermediates generation rules.
#
$(call sm-check-not-empty, sm._this)

$(sm._this).unterminated          := $(strip $($(sm._this).unterminated))
$(sm._this).unterminated.external := $(strip $($(sm._this).unterminated.external))

#$(info any: $(sm.any-unterminated-sources))

ifneq ($(strip $(sm.any-unterminated-sources)),)
  $(sm._this).reduce_level := $($(sm._this).reduce_level)x

  ## Store unterminated intermediates into sm.var.sources.* for make intermediates
  ## rules. And immediately reset the unterminated list.
  $(foreach _, $(sm.var.source_types),\
       $(eval sm.var.sources.$_ := $($(sm._this).unterminated.$_))\
       $(eval $(sm._this).unterminated.$_ :=)\
   )

  ## Call the make-intermediates-rules function to reduce $(sm.var.sources) for
  ## terminated intermediates generation rules.
  $(call sm-check-flavor, sm.fun.make-rules-intermediates, recursive)
  $(call sm.fun.make-rules-intermediates)

  ifdef $(sm._this).unterminated.strange
    ## Does nothing in this case except that the unterminated list should be
    ## cleared.
    $(foreach _, $(sm.var.source_types), $(eval $(sm._this).unterminated.$_ :=))
  else
    ## Go on if unterminated intermediates reproduced.
    ifneq ($(or $($(sm._this).unterminated),$($(sm._this).unterminated.external)),)
      include $(sm.dir.buildsys)/funs/reduce.mk
    endif #$(sm._this).unterminated != <EMPTY>
  endif # $(sm._this).unterminated.strange != <EMPTY>
endif #$(sm._this).unterminated != <EMPTY>
