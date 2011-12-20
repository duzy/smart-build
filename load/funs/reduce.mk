#
# reduce.mk - reduce the $(sm._this).unterminated list until it's empty and
#             producing output into $(sm._this).intermediates, making
#             intermediates generation rules.
#
$(call sm-check-not-empty, sm._this)

$(sm._this).unterminated          := $(strip $($(sm._this).unterminated))
$(sm._this).unterminated.external := $(strip $($(sm._this).unterminated.external))

ifneq ($(or $($(sm._this).unterminated),$($(sm._this).unterminated.external)),)
  $(sm._this).reduce_level := $($(sm._this).reduce_level)x

  ## Store unterminated intermediates into sm.var.sources for make intermediates
  ## rules.
  sm.var.sources          := $($(sm._this).unterminated)
  sm.var.sources.external := $($(sm._this).unterminated.external)

  ## And immediately reset the unterminated list
  $(sm._this).unterminated          :=
  $(sm._this).unterminated.external :=

  ## Call the make-intermediates-rules function to reduce $(sm.var.sources) for
  ## terminated intermediates generation rules.
  $(call sm-check-flavor, sm.fun.make-rules-intermediates, recursive)
  $(call sm.fun.make-rules-intermediates)

  ifdef $(sm._this).unterminated.strange
    ## Does nothing in this case except that the unterminated list should be
    ## cleared.
    $(sm._this).unterminated          :=
    $(sm._this).unterminated.external :=
  else
    ## Go on if unterminated intermediates reproduced.
    ifneq ($(or $($(sm._this).unterminated),$($(sm._this).unterminated.external)),)
      include $(sm.dir.buildsys)/funs/reduce.mk
    endif #$(sm._this).unterminated != <EMPTY>
  endif # $(sm._this).unterminated.strange != <EMPTY>
endif #$(sm._this).unterminated != <EMPTY>
