$(call sm-new-module, android-sdk-use-java-library, android-sdk:apk PLATFORM=android-10)
$(call sm-use, android-sdk-java-library)
#$(call test-check-value-of,sm.this.sources,src/org/smart/test/Foo.java)
$(call sm-build-this)
