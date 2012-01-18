#
$(call go-new-module, 9.a, clib)

sm.this.sources := \
	fmt/charstod.c\
	fmt/pow10.c\
	\
	fmt/dofmt.c\
	fmt/fltfmt.c\
	fmt/fmt.c\
	fmt/fmtfd.c\
	fmt/fmtfdflush.c\
	fmt/fmtlocale.c\
	fmtlock2.c\
	fmt/fmtnull.c\
	fmt/fmtprint.c\
	fmt/fmtquote.c\
	fmt/fmtrune.c\
	fmt/fmtstr.c\
	fmt/fmtvprint.c\
	fmt/fprint.c\
	fmt/nan64.c\
	fmt/print.c\
	fmt/seprint.c\
	fmt/smprint.c\
	fmt/snprint.c\
	fmt/sprint.c\
	fmt/strtod.c\
	fmt/vfprint.c\
	fmt/vseprint.c\
	fmt/vsmprint.c\
	fmt/vsnprint.c\
	\
	fmt/fmtdef.h \
	\
	utf/rune.c\
	utf/utfecpy.c\
	utf/utflen.c\
	utf/utfnlen.c\
	utf/utfrrune.c\
	utf/utfrune.c\
	utf/utfutf.c\
	utf/runetype.c\
	\
	_p9dir.c\
	_exits.c\
	argv0.c\
	atoi.c\
	cleanname.c\
	create.c\
	ctime.c\
	dirfstat.c\
	dirfwstat.c\
	dirstat.c\
	dirwstat.c\
	dup.c\
	errstr.c\
	exec.c\
	execl.c\
	exitcode.c\
	exits.c\
	getenv.c\
	getfields.c\
	getwd.c\
	goos.c\
	main.c\
	nan.c\
	nulldir.c\
	open.c\
	readn.c\
	seek.c\
	strecpy.c\
	sysfatal.c\
	time.c\
	tokenize.c\

ifeq ($(GOHOSTOS),windows)
sm.this.sources +=\
	win32.c\

else
sm.this.sources +=\
	await.c\
	getuser.c\
	jmp.c\
	notify.c\
	rfork.c\

endif

sm.this.defines += -DPLAN9PORT
sm.this.includes += $(go.root)/src/lib9/fmt $(go.root)/src/lib9/utf
sm.this.compile.flags-goos.c := \
  -DGOOS='"$(GOOS)"' \
  -DGOARCH='"$(GOARCH)"' \
  -DGOROOT='"$(GOROOT_FINAL)"' \
  -DGOVERSION='"'"$(GOVERSION)"'"'

$(sm.this.dir:$(sm.top)/%=%)/nan.c: $(sm.this.dir:$(sm.top)/%=%)/fmt/fmtdef.h

sm.this.export.libs += m

$(go-build-this)
