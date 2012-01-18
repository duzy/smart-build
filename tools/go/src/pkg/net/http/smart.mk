#
$(call go-new-module, net/http, pkg)

GOFILES=\
	chunked.go\
	client.go\
	cookie.go\
	filetransport.go\
	fs.go\
	header.go\
	jar.go\
	lex.go\
	request.go\
	response.go\
	server.go\
	sniff.go\
	status.go\
	transfer.go\
	transport.go\

sm.this.sources := $(GOFILES)
sm.this.depends += goal-runtime/debug

$(go-build-this)
