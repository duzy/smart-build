#

$(call sm-new-module, foobar, exe, gcc)

sm.this.verbose := true
sm.this.sources := foo.cpp

## FIXME: sm.this.using not works because of this:
## 
##  foobar/bar/smart.mk:13: *** prerequisites cannot be defined in command scripts
##
#sm.this.using := foobar/bar
#sm.this.using.names := bar


## use sm-import instead of sm.this.using for that purpose
$(call sm-import, foobar/bar)

$(call sm-check-equal,$(sm.module.bar.name),bar)
$(call sm-check-equal,$(sm.module.bar.type),shared)
$(call sm-check-equal,$(sm.module.bar.is_external),)
$(call sm-check-in-list, bar, sm.global.modules)
$(call sm-check-in-list, bar, sm.module.foobar.using_list)

$(call sm-use-external, ../shared)

$(call sm-check-equal,$(sm.module.foo.name),foo)
$(call sm-check-equal,$(sm.module.foo.type),shared+external)
$(call sm-check-equal,$(sm.module.foo.is_external),true)
$(call sm-check-in-list, foo, sm.global.modules)
$(call sm-check-in-list, foo, sm.module.foobar.using_list)

$(sm-build-this)
