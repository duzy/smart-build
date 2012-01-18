#
$(call go-new-module, runtime, pkg)

GOFILES=\
	debug.go\
	error.go\
	extern.go\
	mem.go\
	sig.go\
	softfloat64.go\
	type.go\
	zgoarch_$(GOARCH).go\
	zgoos_$(GOOS).go\
	zruntime_defs_$(GOOS)_$(GOARCH).go\
	zversion.go\

OFILES_darwin=\
	lock_sema.c\

OFILES_freebsd=\
	lock_futex.c\

OFILES_linux=\
	lock_futex.c\

OFILES_netbsd=\
	lock_sema.c\

OFILES_openbsd=\
	lock_sema.c\

OFILES_plan9=\
	lock_sema.c\

OFILES_windows=\
	callback_windows_$(GOARCH).c\
	lock_sema.c\
	zsyscall_windows_$(GOARCH).c\

# 386-specific object files
OFILES_386=\
	vlop_386.c\
	vlrt_386.c\
	traceback_x86.c\

# amd64-specific object files
OFILES_amd64=\
	traceback_x86.c\

# arm-specific object files
OFILES_arm=\
	memset_arm.c\
	softfloat_arm.c\
	vlop_arm.c\
	vlrt_arm.c\
	traceback_arm.c\

OFILES=\
	$(OFILES_$(GOARCH))\
	$(OFILES_$(GOOS))\
	alg.c\
	asm_$(GOARCH).s\
	atomic_$(GOARCH).c\
	cgocall.c\
	chan.c\
	closure_$(GOARCH).c\
	complex.c\
	cpuprof.c\
	float.c\
	hashmap.c\
	iface.c\
	mcache.c\
	mcentral.c\
	mem_$(GOOS).c\
	memmove_$(GOARCH).s\
	mfinal.c\
	mfixalloc.c\
	mgc0.c\
	mheap.c\
	msize.c\
	print.c\
	proc.c\
	rt0_$(GOOS)_$(GOARCH).s\
	rune.c\
	runtime.c\
	signal_$(GOOS)_$(GOARCH).c\
	slice.c\
	symtab.c\
	sys_$(GOOS)_$(GOARCH).s\
	thread_$(GOOS).c\
	zmalloc_$(GOARCH).c\
	zmprof_$(GOARCH).c\
	zruntime1_$(GOARCH).c\
	zsema_$(GOARCH).c\
	zsigqueue_$(GOARCH).c\
	zstring_$(GOARCH).c\
	ztime_$(GOARCH).c\

AUTOHFILES=\
	arch_GOARCH.h\
	os_GOOS.h\
	signals_GOOS.h\
	defs_GOOS_GOARCH.h\
	zasm_GOOS_GOARCH.h\

HFILES=\
	cgocall.h\
	runtime.h\
	hashmap.h\
	malloc.h\
	stack.h\
	\
	type.h\

GOFILES+=$(GOFILES_$(GOOS))

sm.this.sources := $(GOFILES) $(OFILES) $(HFILES)

# special, out of the way compiler flag that means "add runtime metadata to output"
sm.this.compile.flags.go += -+
sm.this.compile.flags.asm += -DGOOS_$(GOOS) -DGOARCH_$(GOARCH)
sm.this.compile.flags.c += -DGOOS_$(GOOS) -DGOARCH_$(GOARCH)
#sm.this.includes += $(sm.this.prefix)

$(sm.this.prefix)/arch_GOARCH.h:      $(go.root)/src/pkg/runtime/arch_$(GOARCH).h
$(sm.this.prefix)/os_GOOS.h:          $(go.root)/src/pkg/runtime/os_$(GOOS).h
$(sm.this.prefix)/signals_GOOS.h:     $(go.root)/src/pkg/runtime/signals_$(GOOS).h
$(sm.this.prefix)/defs_GOOS_GOARCH.h: $(go.root)/src/pkg/runtime/defs_$(GOOS)_$(GOARCH).h
$(sm.this.prefix)/zasm_GOOS_GOARCH.h: $(go.root)/src/pkg/runtime/zasm_$(GOOS)_$(GOARCH).h
$(sm.this.prefix)/%.h:
	@test -f $< && test -d $(@D) && mkdir -p $(@D)
	ln -sf $< $@
$(sm.this.prefix)/asm_$(GOARCH).s: $(sm.this.prefix)/zasm_GOOS_GOARCH.h
$(sm.this.prefix)/signal_$(GOOS)_$(GOARCH).c: $(sm.this.prefix)/signals_GOOS.h
$(sm.this.prefix)/hashmap.c: $(sm.this.prefix)/hashmap.h
$(sm.this.prefix)/mem_$(GOOS).c: \
    $(sm.this.prefix)/defs_GOOS_GOARCH.h\
    $(sm.this.prefix)/os_GOOS.h
$(sm.this.prefix)/cgocall.c: \
    $(sm.this.prefix)/cgocall.h \
    $(sm.this.prefix)/stack.h
$(sm.this.prefix)/traceback_x86.c: \
    $(sm.this.prefix)/runtime.h\
    $(sm.this.prefix)/malloc.h\
    $(sm.this.prefix)/type.h\
    $(sm.this.prefix)/arch_GOARCH.h

$(go-build-this)
