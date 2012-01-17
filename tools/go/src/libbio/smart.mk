#
$(call go-new-module, bio.a, clib)

sm.this.sources := \
	bbuffered.c\
	bfildes.c\
	bflush.c\
	bgetc.c\
	bgetrune.c\
	bgetd.c\
	binit.c\
	boffset.c\
	bprint.c\
	bputc.c\
	bputrune.c\
	brdline.c\
	brdstr.c\
	bread.c\
	bseek.c\
	bwrite.c\

$(go-build-this)
