#
#

this.dir := $(call sm-this-dir)

## Replace NDK's build scripts: 
BUILD_HOST_EXECUTABLE     := $(this.dir)/fake-build-host-executable.mk
BUILD_HOST_STATIC_LIBRARY := $(this.dir)/fake-build-host-static.mk
BUILD_STATIC_LIBRARY      := $(this.dir)/fake-build-static.mk
BUILD_SHARED_LIBRARY      := $(this.dir)/fake-build-shared.mk
BUILD_EXECUTABLE          := $(this.dir)/fake-build-executable.mk
PREBUILT_SHARED_LIBRARY   := $(this.dir)/fake-prebuilt-shared.mk
PREBUILT_STATIC_LIBRARY   := $(this.dir)/fake-prebuilt-static.mk
