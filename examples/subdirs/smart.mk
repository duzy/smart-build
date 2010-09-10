#

this_dir := $(sm-this-dir)
sm.this.dir := $(this_dir)
$(call sm-load-subdirs)
$(call sm-load-module, $(this_dir)/foobar.mk)
