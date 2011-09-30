#

$(call sm-new-module, foo, exe, gcc)

## Turn on verbose to make command lines visible
sm.this.verbose := true

## The flags to be used by the compiler
sm.this.compile.flags := -DTEST=\"$(sm.this.name)\"
sm.this.compile.flags.infile := yes

## The include search path (for compiler's -I switch), each item of this will
## be translated into a -I switch for the compiler by the toolset.
sm.this.includes := $(sm.this.dir)/../include
sm.this.sources := foobar.c

## The flags to be used by the linker
## NOTE: no needs to '-Wl,' or '-Wlinker' to pass linker arguments
sm.this.link.flags := $(if $(sm.os.name.win32),--subsystem=console) -O2
sm.this.link.flags.infile := true

sm.this.link.intermediates.infile := true

## The libraries search path (for linker's -L switch), each item of this will
## be translated into a -L switch similar to 'sm.this.includes'.
sm.this.libdirs := $(sm.this.dir)/../libs

## The libraries to be linked with this module, each item of which will be
## translated into a -l switch in this way:
##	libNAME	-> -lNAME
##	NAME	-> -lNAME
##	-lNAME	-> -lNAME
sm.this.libs :=  -lm
sm.this.libs.infile := true

$(sm-build-this)
