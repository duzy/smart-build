#
$(call go-new-module, archive/tar, pkg)

sm.this.sources := \
	common.go\
	reader.go\
	writer.go\

sm.this.depends += goal-time

$(call go-build-this)
