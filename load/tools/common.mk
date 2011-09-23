#

sm.tool.common.langs := web cweb noweb
sm.tool.common.web.suffix := .web
sm.tool.common.cweb.suffix := .w
sm.tool.common.noweb.suffix := .nw

sm.tool.common.intermediate.suffix.web := .p
sm.tool.common.intermediate.suffix.web.c := .p
sm.tool.common.intermediate.suffix.web.c++ := .p
sm.tool.common.intermediate.suffix.cweb = .c
sm.tool.common.intermediate.suffix.cweb.c = .c
sm.tool.common.intermediate.suffix.cweb.c++ = .cpp
sm.tool.common.intermediate.suffix.noweb :=
sm.tool.common.intermediate.suffix.noweb.c := .c
sm.tool.common.intermediate.suffix.noweb.c++ := .cpp

sm.tool.common.target.lang.web := pascal
sm.tool.common.target.lang.cweb :=
sm.tool.common.target.lang.noweb :=

##################################################

##
##
##
define sm.tool.common.compile.web.private
tangle $(sm.args.sources) && \
mv $(word 1,$(sm.args.sources:%.web=%.p)) $(sm.args.target)
endef #sm.tool.common.compile.web.private

##
##
##
define sm.tool.common.compile.cweb.private
ctangle \
 $(word 1,$(sm.args.sources)) \
 $(or $(word 2,$(sm.args.sources)),-) \
 $(sm.args.target)
endef #sm.tool.common.compile.cweb.private

##
##
##
define sm.tool.common.compile.noweb.private
notangle -$(sm.args.lang) $(sm.args.sources) && \
mv $(word 1,$(sm.args.sources:%.nw=%.p)) $(sm.args.target)
endef #sm.tool.common.compile.noweb.private

sm.tool.common.compile       = $(call sm.tool.common.compile.$(sm.args.lang).private)
sm.tool.common.compile.web   = $(eval sm.args.lang:=web)$(sm.tool.common.compile)
sm.tool.common.compile.cweb  = $(eval sm.args.lang:=cweb)$(sm.tool.common.compile)
sm.tool.common.compile.noweb = $(eval sm.args.lang:=noweb)$(sm.tool.common.compile)

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

