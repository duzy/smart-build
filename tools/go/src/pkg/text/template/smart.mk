#
$(call go-new-module, text/template, pkg)

GOFILES=\
	doc.go\
	exec.go\
	funcs.go\
	helper.go\
	template.go\

sm.this.sources := $(GOFILES)
sm.this.depends += goal-text/template/parse goal-net/url

$(go-build-this)
