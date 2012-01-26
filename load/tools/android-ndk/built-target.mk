#
#
ifeq ($(filter shared,$($(sm._this).toolset.args)),shared)
  .PHONY: ndk-libs
  ndk-libs: ndk-libs-$($(sm._this).name)

  define android-ndk-prepare-libs
  $(eval \
    sm.temp._libs := $(filter %.so, $($(sm._this).targets))
    sm.temp._ndk_lib = libs/$(TARGET_ARCH_ABI)/lib$$(patsubst lib%,%,$$(notdir $$(sm.temp._lib)))
   )\
  $(eval \
    ndk-libs-$($(sm._this).name): goal-$($(sm._this).name)
	@mkdir -p libs/$(TARGET_ARCH_ABI) &&\
     $(foreach sm.temp._lib, $(sm.temp._libs),\
	echo "smart: prepare $(sm.temp._ndk_lib)" &&\
	cp -f $(sm.temp._lib) $(sm.temp._ndk_lib) &&\
      )\
	test $(foreach sm.temp._lib,$(sm.temp._libs),-f $(sm.temp._ndk_lib) -a) -z ''

    sm.temp._ndk_lib =
    sm.temp._libs =
    sm.temp._lib =
   )
  endef #android-ndk-prepare-libs

  $(android-ndk-prepare-libs)

  android-ndk-prepare-libs = $(error android-ndk-prepare-libs is internal)
else # not a shared library
  ##...
endif # if shared library?
