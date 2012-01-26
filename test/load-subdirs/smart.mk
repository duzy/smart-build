$(call test-check-defined, sm.this.dir) ## defined by last loaded module
$(call test-check-defined, sm-load-subdirs)
$(call test-check-flavor,  sm-load-subdirs, recursive)
########## case in -- load module in sub-directories
$(call sm-load-subdirs, subdirs subdir)
########## case out
$(call test-check-undefined,sm.this.dirs)
$(call test-check-value,$(sm.this.dirs),)
$(call test-check-value-of,test.case.subdirs-loaded,1)
$(call test-check-value-of,test.case.subdir-loaded,1)
$(call test-check-not-value,$(sm.this.dir),$(test.temp.this-dir))
$(call test-check-defined,sm.this.dir) ## should not be empty
$(call test-check-value-of,sm.this.dir,subdir)
$(call test-check-defined, sm.module.subdir-foo.name)
$(call test-check-defined, sm.module.subdir-foo.type)
$(call test-check-defined, sm.module.subdir-foo.dir)
$(call test-check-value-of,sm.module.subdir-foo.name,subdir-foo)
$(call test-check-value-of,sm.module.subdir-foo.type,none)
$(call test-check-value-of,sm.module.subdir-foo.dir,subdir)
