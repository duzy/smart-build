#

$(call sm-new-module, foo, exe)

sm.this.sources := foo.cpp

$(sm-build-this)
