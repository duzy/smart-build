#
#
####
test.case.subdirs-loaded := 1
####
$(call test-check-flavor,sm-this-dir,recursive)
$(call test-check-undefined,sm.this.dir)

sm.this.dir := $(sm-this-dir)
sm.this.dir.saved := $(sm.this.dir)
$(call test-check-defined,sm.this.dir)
$(call test-check-flavor,sm-load-subdirs,recursive)
########## case in -- load modules in sub directories
$(call sm-load-subdirs, subdirs subdir)
########## case out
#$(call test-check-undefined,sm.this.dir)
$(call test-check-undefined,sm.this.dirs)
$(call test-check-value-of,test.case.subdirs-subdirs-loaded,1)
$(call test-check-value-of,test.case.subdirs-subdir-loaded,1)
