#
#
$(call test-check-module-empty, sm.module.toolset-clang-shared)
$(call sm-new-module, toolset-clang-shared, clang: shared)

sm.this.defines := -DTEST_STR=\"foo\" -DTEST_NUM=10
sm.this.sources := ../foo.c ../foo.cpp

$(sm-build-this)
