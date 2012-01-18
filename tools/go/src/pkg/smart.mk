#
$(call sm-load-subdirs,\
	errors sync/atomic runtime sync\
	syscall time\
	io os\
	math sort\
	strings\
	path path/filepath\
	strconv io/ioutil\
	unicode unicode/utf8 unicode/utf16 bytes\
	archive/tar\
	bufio compress/flate\
	reflect encoding/binary\
	hash hash/crc32 hash/crc64 archive/zip\
 )
