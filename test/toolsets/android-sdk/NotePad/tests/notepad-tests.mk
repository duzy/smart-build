#
#
#
#
$(call test-check-undefined,sm.this.sources)
$(call test-check-module-empty, sm.module.android-sdk-notepadtests)
$(call sm-new-module, android-sdk-notepadtests, android-sdk: apk PLATFORM=android-10)
$(call test-check-value-of,sm.this.sources,src/com/example/android/notepad/NotePadTest.java)

$(warning info: notepadtests: $(sm.this.sources))
sm.this.sources += $(wildcard ../NotePad/src/com/example/android/notepad/*.java)

$(sm-build-this)
