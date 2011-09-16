#

$(call sm-new-module, foo, shared, gcc)

sm.this.verbose := true
sm.this.sources := foo.cpp
sm.this.compile.flags := -fPIC
sm.this.link.flags := -fPIC
sm.this.depends := foo.txt

foo.txt: ; echo foo > $@

$(sm-generate-implib)
$(sm-build-this)
