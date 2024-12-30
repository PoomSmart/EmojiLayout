PACKAGE_VERSION = 1.2.0

ifeq ($(SIMULATOR),1)
    TARGET = simulator:clang:latest:8.0
    ARCHS = x86_64 i386
else
    TARGET = iphone:clang:latest:6.0
    ARCHS = armv7 arm64
endif

include $(THEOS)/makefiles/common.mk

LIBRARY_NAME = EmojiLayout
$(LIBRARY_NAME)_FILES = PSEmojiLayout+Layout.m PSEmojiLayout+KBResize.m Tweak.xm
$(LIBRARY_NAME)_CFLAGS = -fobjc-arc
$(LIBRARY_NAME)_INSTALL_PATH = /Library/MobileSubstrate/DynamicLibraries/EmojiPort
$(LIBRARY_NAME)_EXTRA_FRAMEWORKS = CydiaSubstrate
$(LIBRARY_NAME)_USE_SUBSTRATE = 1

include $(THEOS_MAKE_PATH)/library.mk
include ../../preferenceloader-sim/locatesim.mk

ifeq ($(SIMULATOR),1)
setup:: clean all
    @rm -f /opt/simject/$(LIBRARY_NAME).dylib
    @cp -v $(THEOS_OBJ_DIR)/$(LIBRARY_NAME).dylib /opt/simject
    @cp -v $(PWD)/$(LIBRARY_NAME).plist /opt/simject
    @sudo mkdir -p $(PL_SIMULATOR_PLISTS_PATH)
    @sudo cp -vR $(PWD)/EmojiLayout $(PL_SIMULATOR_PLISTS_PATH)/
endif
