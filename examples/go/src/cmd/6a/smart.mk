#
$(call go-new-module, 6a, ccmd)

sm.this.sources := \
	y.tab.c\
	lex.c\
	../6l/enam.c\
	a.h\
	y.tab.h\
	../6l/6.out.h\

$(sm.this.dir:$(sm.top)/%=%)/lex.c: \
  $(sm.this.dir:$(sm.top)/%=%)/y.tab.h\
  $(sm.this.dir:$(sm.top)/%=%)/a.h\
  $(sm.this.dir:$(sm.top)/%=%)/../cc/lexbody\
  $(sm.this.dir:$(sm.top)/%=%)/../cc/macbody\

$(sm.this.dir:$(sm.top)/%=%)/../cc/lexbody: $(go.root)/src/cmd/cc/lexbody
$(sm.this.dir:$(sm.top)/%=%)/../cc/macbody: $(go.root)/src/cmd/cc/macbody
$(sm.this.dir:$(sm.top)/%=%)/../cc/%body:
	@echo "go: link $<" && ([[ -d $(@D) ]] || mkdir -p $(@D)) && \
	ln -sf $< $@ || (echo "go: cannot link $@" && false)

$(go-build-this)
