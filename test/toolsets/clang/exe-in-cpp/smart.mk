#
#
$(call test-check-module-empty, sm.this)
$(call test-check-module-empty, sm.module.toolset-clang-exe-in-cpp)
$(call sm-new-module, toolset-clang-exe-in-cpp, clang: exe)

sm.this.defines := -DTEST_STR=\"foo\" -DTEST_NUM=10
sm.this.sources := ../main.cpp

$(sm-build-this)
