##
##  cused.mk - compute used flags recursively
##  
##  inputs:
##	sm.var.temp._use
##	sm._that
##  
# ifeq ($(sm._this),sm.module.cogl)
#   $(info $(sm._this): $($(sm._this).using_list.computed), $(sm.var.temp._use))
#   $(info $($(sm._that).export.compile.flags))
# endif
ifeq ($(filter $(sm.var.temp._use),$($(sm._this).using_list.computed)),)
  $(sm._this).using_list.computed += $(sm.var.temp._use)
  $(sm._this).used.defines        += $($(sm._that).export.defines)
  $(sm._this).used.includes       += $($(sm._that).export.includes)
  $(sm._this).used.compile.flags  += $($(sm._that).export.compile.flags)
  $(sm._this).used.link.flags     += $($(sm._that).export.link.flags)
  $(sm._this).used.libdirs        += $($(sm._that).export.libdirs)
  $(sm._this).used.libs           += $($(sm._that).export.libs)

  ## recursivly include cused.mk
  ${foreach sm.var.temp._use, $($(sm._that).export.use),\
    ${eval sm._that := sm.module.$(sm.var.temp._use)}\
    ${eval include $(sm.dir.buildsys)/cused.mk}\
   }
endif
