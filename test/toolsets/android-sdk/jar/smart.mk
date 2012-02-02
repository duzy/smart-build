$(call sm-new-module, android-sdk-java-library, android-sdk:jar PLATFORM=android-10)
$(call test-check-value-of,sm.this.sources,src/org/smart/test/Foo.java)
$(warning info: $(sm.this.sources))
$(call sm-build-this)
