# -*- mode: makefile-gmake -*-

this_dir := $(sm-this-dir)

#sm.this.dir := $(this_dir)
#$(info $(sm.this.dir), before sm-load-subdirs)

$(call sm-load-subdirs)

#$(info $(sm.this.dir), after sm-load-subdirs)

$(call sm-load-module, $(this_dir)/foobar.mk)
