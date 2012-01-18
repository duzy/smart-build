#
$(call go-new-module, go/parser, pkg)

GOFILES=\
	interface.go\
	parser.go\

sm.this.sources := $(GOFILES)
sm.this.depends +=\
	goal-bytes\
	goal-errors\
	goal-go/ast\
	goal-go/token\
	goal-io\
	goal-io/ioutil\
	goal-os\
	goal-path/filepath\

$(go-build-this)
