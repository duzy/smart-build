#
$(call go-new-module, log/syslog, pkg)

sm.this.sources :=\
	syslog.go\
	syslog_unix.go\

$(go-build-this)
