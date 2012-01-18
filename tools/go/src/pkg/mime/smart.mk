#
$(call go-new-module, mime, pkg)

GOFILES=\
	grammar.go\
	mediatype.go\
	type.go\

GOFILES_freebsd=\
	type_unix.go

GOFILES_darwin=\
	type_unix.go

GOFILES_linux=\
	type_unix.go

GOFILES_netbsd=\
	type_unix.go

GOFILES_openbsd=\
	type_unix.go

GOFILES_plan9=\
	type_unix.go

GOFILES_windows=\
	type_windows.go

sm.this.sources := $(GOFILES) $(GOFILES_$(GOOS))

$(go-build-this)
