#

sm.tool.common.langs := web cweb noweb
sm.tool.common.web.suffix := .web
sm.tool.common.cweb.suffix := .w
sm.tool.common.noweb.suffix := .nw

##################################################



##################################################

define sm.tool.common.rm
$(if $1,rm -f $1)
endef #sm.tool.common.rm

define sm.tool.common.rmdir
$(if $1,rm -rf $1)
endef #sm.tool.common.rmdir

define sm.tool.common.mkdir
$(if $1,mkdir -p $1)
endef #sm.tool.common.mkdir

define sm.tool.common.cp
$(if $(and $1,$2),cp $1 $2,\
  $(error smart: copy command requires more than two args))
endef #sm.tool.common.cp

define sm.tool.common.mv
$(if $(and $1,$2),mv $1 $2,\
  $(error smart: move command requires more than two args))
endef #sm.tool.common.mv

define sm.tool.common.ln
$(if $(and $1,$2),ln -sf $1 $2)
endef #sm.tool.common.ln

