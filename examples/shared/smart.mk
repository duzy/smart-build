#

$(call sm-new-module, foo, shared, gcc)

$(call sm-check-not-empty,sm.this.dir)
$(call sm-check-not-empty,sm.this.name)
$(call sm-check-not-empty,sm.this.suffix)
$(call sm-check-not-empty,sm.this.makefile)
$(call sm-check-not-empty,sm.this.out_implib)
$(call sm-check-in-list,foo,sm.global.modules)
$(call sm-check-equal,$(sm.this.name),foo)
ifeq ($(sm.this.is_external),true)
  $(call sm-check-equal,$(sm.this.type),shared+external)
else
  $(call sm-check-equal,$(sm.this.type),shared)
endif
$(call sm-check-equal,$(sm.this.suffix),.so)
$(call sm-check-equal,$(sm.this.out_implib),foo)

ifeq ($(shell uname -m),x86_64)
M64_FLAGS := -fPIC
endif

sm.this.verbose ?= true

sm.this.compile.flags := $(M64_FLAGS) -DTEST=\"$(sm.this.name)\"
sm.this.includes := $(sm.this.dir)/../include
sm.this.sources := foobar.c
sm.this.link.flags := $(M64_FLAGS) $(if $(sm.os.name.win32),--subsystem=console)
sm.this.libdirs := $(sm.this.dir)/../libs
sm.this.libs :=

sm.this.export.includes := $(sm.this.dir)
sm.this.export.defines := -Dfoo=\"defined in external foo\"
sm.this.export.libdirs := $(sm.this.dir)/$(sm.out.lib)
sm.this.export.libs := foo

$(sm-generate-implib)
$(sm-build-this)
