#
$(call go-new-module, go/doc, pkg)

GOFILES=\
	comment.go\
	doc.go\
	example.go\
	exports.go\
	filter.go\
	reader.go\

sm.this.sources := $(GOFILES)
sm.this.depends += goal-text/template

$(go-build-this)
