#
$(call go-new-module, go/ast, pkg)

GOFILES=\
	ast.go\
	filter.go\
	import.go\
	print.go\
	resolve.go\
	scope.go\
	walk.go\

sm.this.sources := $(GOFILES)
sm.this.depends +=\
  goal-go/token\
  goal-go/scanner\
  goal-go/parser\

$(go-build-this)
