#
$(call go-new-module, hash/crc32, pkg)

ifeq ($(GOARCH), amd64)
	ARCH_GOFILES=crc32_amd64.go
	OFILES=crc32_amd64.6
else
	ARCH_GOFILES=crc32_generic.go
endif

GOFILES=\
	crc32.go\
	$(ARCH_GOFILES)

sm.this.sources := $(GOFILES)

$(go-build-this)
