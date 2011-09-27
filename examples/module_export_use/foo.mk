#

$(call sm-new-module, foo, exe, gcc)

sm.this.sources := foo.cpp

## module load subpath (this will force loading SMART_MODULE_PATH/foobar/bar)
sm.this.using := foobar/bar

## module names
#sm.this.using.names := bar

$(sm-build-this)
