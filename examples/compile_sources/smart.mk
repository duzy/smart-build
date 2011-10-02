#

$(call sm-new-module, foo, executable, gcc)

$(call sm-check-not-empty,sm.this.dir)
$(call sm-check-not-empty,sm.this.type)
$(call sm-check-not-empty,sm.this.name)
#$(call sm-check-not-empty,sm.this.suffix)
$(call sm-check-not-empty,sm.this.makefile)
$(call sm-check-in-list,foo,sm.global.modules)
$(call sm-check-equal,$(sm.this.name),foo)
$(call sm-check-equal,$(sm.this.type),exe)
$(call sm-check-equal,$(sm.this.suffix),$(if $(sm.os.name.win32),.exe))

## Turn on verbose to make command lines visible
sm.this.verbose := true
sm.this.compile.flags.infile := true

## The include search path (for compiler's -I switch), each item of this will
## be translated into a -I switch for the compiler by the toolset.
sm.this.includes := $(sm.this.dir)/../include

## The flags to be used by the linker
## NOTE: no needs to '-Wl,' or '-Wlinker' to pass linker arguments
sm.this.link.flags := $(if $(sm.os.name.win32),--subsystem=console) -DFOO

## The libraries search path (for linker's -L switch), each item of this will
## be translated into a -L switch similar to 'sm.this.includes'.
sm.this.libdirs := $(sm.this.dir)/../libs

## The libraries to be linked with this module, each item of which will be
## translated into a -l switch in this way:
##	libNAME	-> -lNAME
##	NAME	-> -lNAME
##	-lNAME	-> -lNAME
sm.this.libs := 

sm.this.compile.flags := -DTEST=\"foo\"
sm.this.sources := foo.c
$(sm-compile-sources)

sm.this.compile.flags := -DTEST=\"bar\"
sm.this.sources := bar.c
$(sm-compile-sources)

sm.this.compile.flags := -DTEST=\"foobar\"
sm.this.sources := foobar.c
$(sm-build-this)

