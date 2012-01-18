#
$(call go-new-module, reflect, pkg)

GOFILES=\
	deepequal.go\
	type.go\
	value.go\

sm.this.sources := $(GOFILES)
sm.this.depends += goal-strconv

$(go-build-this)
