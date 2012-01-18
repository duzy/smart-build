#
$(call go-new-module, cgo, cmd)

sm.this.sources := \
	ast.go\
	gcc.go\
	godefs.go\
	main.go\
	out.go\
	util.go\

sm.this.depends += \
  goal-crypto/md5\
  goal-debug/dwarf\
  goal-debug/elf\
  goal-debug/pe\
  goal-debug/macho\
  goal-fmt\
  goal-flag\
  goal-go/ast\
  goal-go/printer\
  goal-go/parser\
  goal-os/exec\

$(go-build-this)
