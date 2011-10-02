#

$(call sm-new-module, foobar, exe, gcc)

sm.this.verbose := true
sm.this.sources := foo.cpp

## FIXME: sm.this.using not works because of this:
## 
##  foobar/bar/smart.mk:13: *** prerequisites cannot be defined in command scripts
##
#sm.this.using := foobar/bar

## module names
#sm.this.using.names := bar

## use sm-import instead of sm.this.using for that purpose
$(call sm-import, foobar/bar)

$(call sm-check-in-list, bar, sm.global.modules)
$(call sm-check-in-list, bar, sm.module.foobar.using_list)

$(call sm-use-external, ../shared)

$(call sm-check-in-list, foo, sm.global.modules)
$(call sm-check-in-list, foo, sm.module.foobar.using_list)
$(call sm-check-equal,foo,$(sm.module.foo.name))

$(sm-build-this)
