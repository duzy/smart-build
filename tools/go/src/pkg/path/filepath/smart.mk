#
$(call go-new-module, path/filepath, pkg)

GOFILES=\
	match.go\
	path.go\

GOFILES_freebsd=\
	path_unix.go

GOFILES_darwin=\
	path_unix.go

GOFILES_linux=\
	path_unix.go

GOFILES_netbsd=\
	path_unix.go

GOFILES_openbsd=\
	path_unix.go

GOFILES_plan9=\
	path_plan9.go

GOFILES_windows=\
	path_windows.go

sm.this.sources := $(GOFILES) $(GOFILES_$(GOOS))

$(go-build-this)
