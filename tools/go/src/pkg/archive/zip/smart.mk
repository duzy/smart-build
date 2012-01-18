#
$(call go-new-module, archive/zip, pkg)

sm.this.sources := \
	reader.go\
	struct.go\
	writer.go\

sm.this.depends += goal-compress/flate goal-hash/crc32

$(call go-build-this)
