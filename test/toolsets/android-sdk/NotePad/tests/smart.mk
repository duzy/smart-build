#
#
#
#
$(call test-check-undefined,sm.this.sources)
$(call test-check-module-empty, sm.module.android-sdk-notepadtests)
$(call sm-new-module, android-sdk-notepadtests, android-sdk: apk PLATFORM=android-10)
$(call test-check-value-of,sm.this.sources,src/com/example/android/notepad/NotePadTest.java)

$(warning info: sources: $(sm.this.sources))
sm.this.sources += $(wildcard ../src/com/example/android/notepad/*.java)
sm.this.sources += ../out/android-sdk/debug/android-sdk-notepad/res/com/example/android/notepad/R.java
$(warning info: sources: $(sm.this.sources))

$(sm-build-this)
