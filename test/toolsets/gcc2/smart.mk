$(call sm-new-module, foo, gcc2: exe)

sm.this.sources := foo.c foo.cpp foo.s main.c

$(sm-build-this)
