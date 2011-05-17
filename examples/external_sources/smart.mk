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

## Turn off verbose to make command lines invisible
sm.this.verbose := false

## Choose a toolset (doing this will enable tools/$(sm.this.toolset).mk),
## if not doing this, the old style of build system will be used (which only
## supports gcc toolset).
#sm.this.toolset := 

## The flags to be used by the compiler
sm.this.compile.flags := -DTEST=\"$(sm.this.name)\"

## External sources is NOT related to $(sm.this.dir)
sm.this.sources.external := $(sm.this.dir)/foobar.c

## The flags to be used by the linker
## NOTE: no needs to '-Wl,' or '-Wlinker' to pass linker arguments
sm.this.link.flags := $(if $(sm.os.name.win32),--subsystem=console)

$(sm-build-this)
