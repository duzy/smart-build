#
$(call go-new-module, 6a, ccmd)

sm.this.sources := y.tab.c ../6l/enam.c
sm.this.sources := \
	lex.c\
	a.h\
	../6l/6.out.h\

prefix := $(sm.this.dir:$(sm.top)/%=%)
$(prefix)/lex.c: \
  $(prefix)/y.tab.h\
  $(prefix)/a.h\
  $(prefix)/../cc/lexbody\
  $(prefix)/../cc/macbody\

$(prefix)/../cc/lexbody: $(go.root)/src/cmd/cc/lexbody
$(prefix)/../cc/macbody: $(go.root)/src/cmd/cc/macbody
$(prefix)/../cc/%body:
	@echo "go: link $<" && ([[ -d $(@D) ]] || mkdir -p $(@D)) && \
	ln -sf $< $@ || (echo "go: cannot link $@" && false)

$(prefix)/../6l/enam.c: $(dir $(prefix))6l/enam.c

$(go-build-this)
