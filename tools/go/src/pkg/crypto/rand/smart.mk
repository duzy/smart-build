#
$(call go-new-module, crypto/rand, pkg)

GOFILES=\
	rand.go\
	util.go\

GOFILES_freebsd=\
	rand_unix.go\

GOFILES_darwin=\
	rand_unix.go\

GOFILES_linux=\
	rand_unix.go\

GOFILES_openbsd=\
	rand_unix.go\

GOFILES_windows=\
	rand_windows.go\

sm.this.sources := $(GOFILES) $(GOFILES_$(GOOS))
sm.this.depends += goal-crypto goal-math/big

$(go-build-this)
