define vars
FOO=foo;
BAR=bar;
FOOBAR=foo'bar;
BLAH=blah'blah"blah=blah\;blah=blah
endef #"

define newline


endef #newline

define linefeed

endef #linefeed

$(info -v$(subst ;,' -v,$(subst =,=',$(subst $(newline),,$(subst $(linefeed),,$(value vars))))))
$(eval $(subst ;,,$(value vars)))

## NOTE: These works without "subst":
## 
##   $(shell awk -f interpolate.awk -- -vars '$(vars)' interpolate-test.in)
## 
all: interpolate-test.in
	awk -f interpolate.awk -- -vars "$(subst ",\",$(subst $(newline),,$(subst $(linefeed),,$(vars))))" $<
