#

$(call sm-new-module, foo, depends)

sm.this.depends := foo.txt

foo.txt: ; echo foo > $@

$(sm-build-this)
