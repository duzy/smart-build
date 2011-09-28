#

$(call sm-new-module, foo, exe, gcc)

sm.this.verbose := true
sm.this.sources := foo.cpp

## FIXME: sm.this.using not works because of this:
## 
##  foobar/bar/smart.mk:13: *** prerequisites cannot be defined in command scripts
##
#sm.this.using := foobar/bar

## module names
#sm.this.using.names := bar

## use sm-use-module instead of sm.this.using for that purpose
$(call sm-use-module, foobar/bar)

$(sm-build-this)
