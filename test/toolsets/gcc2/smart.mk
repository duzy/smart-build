$(call sm-new-module, foo, gcc: headers exe)

sm.this.headers := foo.h
sm.this.headers.foo := foo.h
sm.this.headers.foobar := foo.h
sm.this.sources := foo.c foo.cpp foo.s main.c

$(sm-build-this)
