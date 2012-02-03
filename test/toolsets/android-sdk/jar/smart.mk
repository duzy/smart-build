$(call sm-new-module, android-sdk-java-library, android-sdk:jar PLATFORM=android-10)
$(call test-check-value-of,sm.this.sources,src/org/smart/test/Foo.java)
$(warning info: $(sm.this.sources))
sm.this.export.classpath := $(sm.out)/android-sdk-java-library/library.jar
$(call sm-build-this)
