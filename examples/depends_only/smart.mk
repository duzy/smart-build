#

$(call sm-new-module, foo, depends)

sm.this.depends := $(sm.out)/foo.txt
sm.this.clean_steps := rm-foo.txt

$(sm.out)/foo.txt: ; mkdir -p $(@D) && echo foo > $@
rm-foo.txt: ; rm -vf $(sm.out)/foo.txt

$(sm-build-this)
