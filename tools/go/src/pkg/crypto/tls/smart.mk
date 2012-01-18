#
$(call go-new-module, crypto/tls, pkg)

GOFILES_$(GOOS) :=
GOFILES=\
	alert.go\
	cipher_suites.go\
	common.go\
	conn.go\
	handshake_client.go\
	handshake_messages.go\
	handshake_server.go\
	key_agreement.go\
	prf.go\
	tls.go\

ifeq ($(CGO_ENABLED),1)
CGOFILES_darwin=\
	root_darwin.go
else
GOFILES_darwin+=root_stub.go
endif

GOFILES_freebsd+=root_unix.go
GOFILES_linux+=root_unix.go
GOFILES_netbsd+=root_unix.go
GOFILES_openbsd+=root_unix.go
GOFILES_plan9+=root_stub.go
GOFILES_windows+=root_windows.go

GOFILES+=$(GOFILES_$(GOOS))
ifneq ($(CGOFILES_$(GOOS)),)
CGOFILES+=$(CGOFILES_$(GOOS))
endif

sm.this.sources := $(GOFILES)
sm.this.depends += goal-crypto goal-net

$(go-build-this)
