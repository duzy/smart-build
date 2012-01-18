#
$(call go-new-module, mime/multipart, pkg)

GOFILES=\
	formdata.go\
	multipart.go\
	writer.go\

sm.this.sources := $(GOFILES)
sm.this.depends += goal-net/textproto

$(go-build-this)
