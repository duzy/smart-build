#
$(call go-new-module, sync, pkg)

sm.this.sources := \
	cond.go\
	mutex.go\
	once.go \
	rwmutex.go\
	waitgroup.go\

sm.this.depends += goal-runtime goal-sync/atomic

$(go-build-this)
