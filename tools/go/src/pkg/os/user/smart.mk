#
$(call go-new-module, os/user, pkg)

GOFILES_$(GOOS) :=
GOFILES=\
	user.go\

ifeq ($(CGO_ENABLED),1)
CGOFILES_linux=\
	lookup_unix.go
CGOFILES_freebsd=\
	lookup_unix.go
CGOFILES_darwin=\
	lookup_unix.go
endif

ifneq ($(CGOFILES_$(GOOS)),)
CGOFILES+=$(CGOFILES_$(GOOS))
else
GOFILES+=lookup_stubs.go
endif

sm.this.sources := $(GOFILES) $(GOFILES_$(GOOS))
sm.this.depends += goal-syscall goal-time

$(go-build-this)
