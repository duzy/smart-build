##
##  cused.mk - compute used flags recursively
##  
##  inputs:
##	sm._that
##	sm.var._use
##  
ifeq ($(filter $(sm.var._use),$($(sm._this).using_list.computed)),)
  $(sm._this).using_list.computed += $(sm.var._use)

  define sm-copy-used-prop
  $(eval #
    ifneq ($_,use)
      $(sm._this).used.$_ := $($(sm._this).used.$_) $($(sm._that).export.$_)
    endif
   )
  endef #sm-copy-used-prop

  sm.temp._export_vars := $(filter $(sm._that).export.%, $(.VARIABLES))
  $(foreach _, $(patsubst $(sm._that).export.%,%, $(sm.temp._export_vars)),\
       $(sm-copy-used-prop))

  ## recursivly include cused.mk
  $(foreach sm.var._use, $($(sm._that).export.use),\
    $(eval sm._that := sm.module.$(sm.var._use))\
    $(eval include $(sm.dir.buildsys)/funs/use.mk)\
   )
endif
