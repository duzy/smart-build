#
$(call go-new-module, os/exec, pkg)

GOFILES=\
	exec.go\

GOFILES_freebsd=\
	lp_unix.go\

GOFILES_darwin=\
	lp_unix.go\

GOFILES_linux=\
	lp_unix.go\

GOFILES_netbsd=\
	lp_unix.go\

GOFILES_openbsd=\
	lp_unix.go\

GOFILES_windows=\
	lp_windows.go\

GOFILES_plan9=\
	lp_plan9.go\

sm.this.sources := $(GOFILES) $(GOFILES_$(GOOS))

$(go-build-this)
