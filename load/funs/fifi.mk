#
#
sm.temp._find_levels := x $(sm.temp._find_levels)
sm.temp._files := $(wildcard $(sm.temp._find_next)/*)

sm.temp._all_found_files += $(filter $(sm.temp._find_pattern),$(sm.temp._files))

sm.temp._files := $(filter-out $(sm.temp._find_pattern),$(sm.temp._files))
ifdef sm.temp._files
  sm.temp._find_stack += $(sm.temp._files)
endif

#$(info find:$(words $(sm.temp._find_levels)): $(sm.temp._find_stack))

sm.temp._find_next := $(firstword $(sm.temp._find_stack))
sm.temp._find_stack := $(filter-out $(sm.temp._find_next),$(sm.temp._find_stack))
ifdef sm.temp._find_next
  include $(sm.dir.buildsys)/funs/fifi.mk
endif
