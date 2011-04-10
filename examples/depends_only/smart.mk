#

$(call sm-new-module, foo, depends)

sm.this.verbose := true
sm.this.toolset := gcc

sm.this.depends := foo.txt

foo.txt: ; echo foo > $@

$(sm-build-this)
