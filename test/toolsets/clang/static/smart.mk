#
#
$(call test-check-module-empty, sm.module.toolset-clang-static)
$(call sm-new-module, toolset-clang-static, clang: static)

sm.this.defines := -DTEST_STR=\"foo\" -DTEST_NUM=10
sm.this.sources := ../foo.c ../foo.cpp

$(sm-build-this)
