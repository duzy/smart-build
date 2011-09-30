# -*- mode: makefile-gmake -*-

this_dir := $(sm-this-dir)

$(call sm-load-subdirs)

$(call sm-load-module, $(this_dir)/foobar.mk)
