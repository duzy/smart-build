#
$(call go-new-module, runtime/cgo, pkg)

OFILES:=
CGO_OFILES:=
GOFILES=\
	cgo.go\

ifeq ($(CGO_ENABLED),1)

# Unwarranted chumminess with Make.pkg's cgo rules.
# Do not try this at home.
CGO_OFILES=\
	gcc_$(GOARCH).S\
	gcc_$(GOOS)_$(GOARCH).c\
	gcc_util.c\

ifeq ($(GOOS),windows)
CGO_LDFLAGS=-lm -mthreads
else
CGO_LDFLAGS=-lpthread
CGO_OFILES+=gcc_setenv.c\

endif

OFILES=\
	iscgo.c\
	callbacks.c\
	_cgo_import.c\
	$(CGO_OFILES)\

ifeq ($(GOOS),freebsd)
OFILES+=\
	freebsd.c\

endif

endif

sm.this.sources := $(GOFILES) $(OFILES)

$(go-build-this)
