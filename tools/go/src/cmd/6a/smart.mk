#
$(call go-new-module, 6a, ccmd)

sm.this.sources.c := y.tab.c ../6l/enam.c
sm.this.sources := \
	lex.c\
	a.h a.y\
	../6l/6.out.h\

$(sm.this.prefix)/../6l/enam.c: $(dir $(sm.this.prefix))6l/enam.c

$(sm.this.prefix)/lex.c: \
    $(sm.this.prefix)/y.tab.h\
    $(sm.this.prefix)/a.h\
    $(sm.this.prefix)/../cc/lexbody\
    $(sm.this.prefix)/../cc/macbody\

$(sm.this.prefix)/../cc/lexbody: $(go.root)/src/cmd/cc/lexbody
$(sm.this.prefix)/../cc/macbody: $(go.root)/src/cmd/cc/macbody
$(sm.this.prefix)/../cc/%body:
	([[ -d $(@D) ]] || mkdir -p $(@D)) && \
	ln -sf $< $@ || (echo "go: cannot link $@" && false)

$(go-build-this)
