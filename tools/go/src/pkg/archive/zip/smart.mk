#
$(call go-new-module, archive/zip, pkg)

sm.this.sources := \
	reader.go\
	struct.go\
	writer.go\

$(call go-build-this)
