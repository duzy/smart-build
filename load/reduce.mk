#
# reduce.mk - reduce the $(sm._this).unterminated list until it's empty and
#             producing output into $(sm._this).intermediates, making
#             intermediates generation rules.
#
$(sm._this).unterminated          := $(strip $($(sm._this).unterminated))
$(sm._this).unterminated.external := $(strip $($(sm._this).unterminated.external))

ifneq ($(or $($(sm._this).unterminated),$($(sm._this).unterminated.external)),)
  ## Store unterminated intermediates into sm.var.sources for make intermediates
  ## rules.
  sm.var.sources          := $($(sm._this).unterminated)
  sm.var.sources.external := $($(sm._this).unterminated.external)

  ## And immediately reset the unterminated list
  $(sm._this).unterminated          :=
  $(sm._this).unterminated.external :=

  ## Call the make-intermediates-rules function to reduce $(sm.var.sources) for
  ## terminated intermediates generation rules.
  $(call sm.fun.make-intermediates-rules)

  ## go on if unterminated intermediates reproduced
  ifneq ($(or $($(sm._this).unterminated),$($(sm._this).unterminated.external)),)
    include $(sm.dir.buildsys)/reduce.mk
  endif #$(sm._this).unterminated != <EMPTY>
endif #$(sm._this).unterminated != <EMPTY>
