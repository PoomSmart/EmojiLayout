PACKAGE_VERSION = 1.1.18

ifeq ($(SIMULATOR),1)
	TARGET = simulator:clang:latest:8.0
	ARCHS = x86_64 i386
else
	TARGET = iphone:clang:latest:6.0
	ARCHS = armv7 arm64
endif

include $(THEOS)/makefiles/common.mk

LIBRARY_NAME = EmojiLayout
EmojiLayout_FILES = PSEmojiLayout+Layout.m PSEmojiLayout+KBResize.m Tweak.xm
EmojiLayout_INSTALL_PATH = /Library/MobileSubstrate/DynamicLibraries/EmojiPort
EmojiLayout_EXTRA_FRAMEWORKS = CydiaSubstrate
EmojiLayout_USE_SUBSTRATE = 1

include $(THEOS_MAKE_PATH)/library.mk
include ../preferenceloader-sim/locatesim.mk

ifeq ($(SIMULATOR),1)
setup:: clean all
	@rm -f /opt/simject/$(LIBRARY_NAME).dylib
	@cp -v $(THEOS_OBJ_DIR)/$(LIBRARY_NAME).dylib /opt/simject
	@cp -v $(PWD)/$(LIBRARY_NAME).plist /opt/simject
	$(ECHO_NOTHING)find $(PWD)/EmojiLayout -name .DS_Store -delete$(ECHO_END)
	@sudo mkdir -p $(PL_SIMULATOR_PLISTS_PATH)
	@sudo cp -vR $(PWD)/EmojiLayout $(PL_SIMULATOR_PLISTS_PATH)/
else
internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp -R EmojiLayout $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/EmojiLayout$(ECHO_END)
	$(ECHO_NOTHING)find $(THEOS_STAGING_DIR) -name .DS_Store -delete$(ECHO_END)
endif
