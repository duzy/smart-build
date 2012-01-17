#
$(call go-new-module, archive/tar, pkg)

sm.this.sources := \
	common.go\
	reader.go\
	writer.go\

$(call go-build-this)
