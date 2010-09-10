#

$(call sm-new-module, bar, exe)

sm.this.sources := bar.cpp

$(sm-build-this)
