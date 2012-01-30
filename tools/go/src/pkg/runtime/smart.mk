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

AUTOGEN_GOFILES=\
	zgoarch_$(GOARCH).go\
	zgoos_$(GOOS).go\
	zruntime_defs_$(GOOS)_$(GOARCH).go\
	zversion.go\

AUTOGEN_CFILES=\
	zmalloc_$(GOARCH).c\
	zmprof_$(GOARCH).c\
	zruntime1_$(GOARCH).c\
	zsema_$(GOARCH).c\
	zsigqueue_$(GOARCH).c\
	zstring_$(GOARCH).c\
	ztime_$(GOARCH).c\

AUTOGEN_FILES = $(AUTOGEN_GOFILES) $(AUTOGEN_CFILES)

sm.this.sources := $(GOFILES) $(OFILES) $(HFILES)
sm.this.sources.go := $(AUTOGEN_GOFILES)
sm.this.sources.c := $(AUTOGEN_CFILES)

# special, out of the way compiler flag that means "add runtime metadata to output"
sm.this.compile.flags.go += -+
sm.this.compile.flags.asm += -DGOOS_$(GOOS) -DGOARCH_$(GOARCH)
sm.this.compile.flags.c += -DGOOS_$(GOOS) -DGOARCH_$(GOARCH)
#sm.this.includes += $(sm.this.prefix)

$(sm.this.prefix)/asm_$(GOARCH).s:		$(sm.this.prefix)/zasm_GOOS_GOARCH.h
$(sm.this.prefix)/signal_$(GOOS)_$(GOARCH).c:	$(sm.this.prefix)/signals_GOOS.h
$(sm.this.prefix)/hashmap.c:			$(sm.this.prefix)/hashmap.h
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
$(sm.this.prefix)/zmalloc_amd64.c: \
    $(sm.this.prefix)/runtime.h\
    $(sm.this.prefix)/malloc.h\
    $(sm.this.prefix)/type.h\
    $(sm.this.prefix)/arch_GOARCH.h\
    $(sm.this.prefix)/defs_GOOS_GOARCH.h\
    $(sm.this.prefix)/os_GOOS.h\

$(sm.this.prefix)/goc2c.c:	$(go.root)/src/pkg/runtime/goc2c.c ; ln -sf $< $@
$(sm.this.prefix)/mkversion.c:	$(go.root)/src/pkg/runtime/mkversion.c ; ln -sf $< $@

$(sm.out.bin)/quietgcc: $(go.root)/src/quietgcc.bash
	rm -rf $@ && sed -e "s|@CC@|gcc|" < $< > $@ && test -f $@ && chmod +x $@ || rm -rf $@

$(sm.this.prefix)/arch_GOARCH.h:      $(sm.this.prefix)/arch_$(GOARCH).h
$(sm.this.prefix)/os_GOOS.h:          $(sm.this.prefix)/os_$(GOOS).h
$(sm.this.prefix)/signals_GOOS.h:     $(sm.this.prefix)/signals_$(GOOS).h
$(sm.this.prefix)/defs_GOOS_GOARCH.h: $(sm.this.prefix)/defs_$(GOOS)_$(GOARCH).h
$(sm.this.prefix)/zasm_GOOS_GOARCH.h: $(sm.this.prefix)/zasm_$(GOOS)_$(GOARCH).h
$(sm.this.prefix)/%_GOARCH.h $(sm.this.prefix)/%_GOOS.h:
	@test -f $< && test -d $(@D) && mkdir -p $(@D)
	cp -f $< $@
#	cd $(@D) && cp -f $(<F) $(@F)
$(sm.this.prefix)/%.h : $(go.root)/src/pkg/runtime/%.h
	@test -f $< && test -d $(@D) && mkdir -p $(@D)
	ln -sf $< $@
$(sm.this.prefix)/%.goc: $(go.root)/src/pkg/runtime/%.goc
	@test -f $< && test -d $(@D) && mkdir -p $(@D)
	ln -sf $< $@
$(sm.this.prefix)/%.sh: $(go.root)/src/pkg/runtime/%.sh
	@test -f $< && test -d $(@D) && mkdir -p $(@D)
	ln -sf $< $@
$(sm.this.prefix)/autogen.sh: $(go.root)/src/pkg/runtime/autogen.sh
	rm -rf $@ && sed -e "s|\$$GOROOT/include|$(go.root)/include|;s|\$$GOROOT/lib|$(sm.top)/out/gcc/$(sm.config.variant)/lib|;" < $< > $@ && chmod +x $@ || rm -rf $@

cp_runtime_arch_GOARCH_h := \
  cp $(sm.this.prefix)/arch_$(GOARCH).h $(sm.this.prefix)/arch_GOARCH.h &&\
  cp $(sm.this.prefix)/defs_$(GOOS)_$(GOARCH).h $(sm.this.prefix)/defs_GOOS_GOARCH.h &&\
  cp $(sm.this.prefix)/os_$(GOOS).h $(sm.this.prefix)/os_GOOS.h &&\
  true

$(addprefix $(sm.this.prefix)/,$(AUTOGEN_FILES)): \
    $(sm.this.prefix)/autogen.sh\
    $(sm.this.prefix)/../../buildinfo.sh\
    $(sm.this.prefix)/mkgodefs.sh\
    $(sm.this.prefix)/mkasmh.sh\
    $(sm.this.prefix)/proc.c\
    $(sm.this.prefix)/iface.c\
    $(sm.this.prefix)/hashmap.c\
    $(sm.this.prefix)/chan.c\
    $(sm.this.prefix)/goc2c.c\
    $(sm.this.prefix)/mkversion.c\
    $(sm.this.prefix)/malloc.goc\
    $(sm.this.prefix)/mprof.goc\
    $(sm.this.prefix)/runtime1.goc\
    $(sm.this.prefix)/sema.goc\
    $(sm.this.prefix)/sigqueue.goc\
    $(sm.this.prefix)/string.goc\
    $(sm.this.prefix)/syscall_windows.goc\
    $(sm.this.prefix)/time.goc\
    $(sm.this.prefix)/arch_arm.h\
    $(sm.this.prefix)/arch_386.h\
    $(sm.this.prefix)/arch_amd64.h\
    $(sm.this.prefix)/defs_linux_arm.h\
    $(sm.this.prefix)/defs_linux_386.h\
    $(sm.this.prefix)/defs_linux_amd64.h\
    $(sm.this.prefix)/defs_darwin_386.h\
    $(sm.this.prefix)/defs_darwin_amd64.h\
    $(sm.this.prefix)/defs_freebsd_386.h\
    $(sm.this.prefix)/defs_freebsd_amd64.h\
    $(sm.this.prefix)/defs_netbsd_386.h\
    $(sm.this.prefix)/defs_netbsd_amd64.h\
    $(sm.this.prefix)/defs_openbsd_386.h\
    $(sm.this.prefix)/defs_openbsd_amd64.h\
    $(sm.this.prefix)/defs_plan9_386.h\
    $(sm.this.prefix)/defs_windows_386.h\
    $(sm.this.prefix)/defs_windows_amd64.h\
    $(sm.this.prefix)/os_linux.h\
    $(sm.this.prefix)/os_darwin.h\
    $(sm.this.prefix)/os_freebsd.h\
    $(sm.this.prefix)/os_netbsd.h\
    $(sm.this.prefix)/os_openbsd.h\
    $(sm.this.prefix)/os_plan9.h\
    $(sm.this.prefix)/os_windows.h\
    $(sm.this.prefix)/signals_linux.h\
    $(sm.this.prefix)/signals_darwin.h\
    $(sm.this.prefix)/signals_freebsd.h\
    $(sm.this.prefix)/signals_netbsd.h\
    $(sm.this.prefix)/signals_openbsd.h\
    $(sm.this.prefix)/signals_plan9.h\
    $(sm.this.prefix)/signals_windows.h\
    $(sm.out.bin)/quietgcc
	cd $(<D) && export PATH="$(sm.top)/$(sm.out.bin):$$PATH" && GOROOT="$(sm.top)/out/gcc/$(sm.config.variant)" GOOS="$(GOOS)" GOARCH="$(GOARCH)" ./$(<F) && rm -rf z.tmp || rm -rf z.tmp $(AUTOGEN_FILES)$(foreach _,$(AUTOGEN_FILES),&& test -f $_)
	$(cp_runtime_arch_GOARCH_h)

$(go-build-this)
