define vars
FOO=foo
BAR=bar
FOOBAR=foo'bar
BLAH=blah'blah"blah=blah\;blah=blah
endef #"

define newline


endef #newline

define linefeed

endef #linefeed

sm.dir.buildsys := ..
include ../defuns.mk
$(call sm-interpolate, vars, interpolate-test)
$(call sm-check-equal,$(FOO),foo)
$(call sm-check-equal,$(FOOBAR),foo'bar) #'
$(call sm-check-equal,$(BAR),bar)
$(call sm-check-equal,$(BLAH),blah'blah"blah=blah\;blah=blah) #'

## NOTE: These works without "subst":
## 
##   $(shell awk -f interpolate.awk -- -vars '$(vars)' interpolate-test.in)
## 
all: interpolate-test
