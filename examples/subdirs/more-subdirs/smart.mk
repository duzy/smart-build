# -*- mode: makefile-gmake -*-

#sm.this.dir := $(sm-this-dir)
#$(info $(sm.this.dir))
$(call sm-check-empty, sm.this.dir)
$(call sm-load-subdirs)