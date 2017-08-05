PACKAGE_VERSION = 1.1.13

ifeq ($(SIMULATOR),1)
	TARGET = simulator:clang:latest:8.0
	ARCHS = x86_64 i386
else
	TARGET = iphone:clang:latest:5.0
endif

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = EmojiLayout
EmojiLayout_FILES = PSEmojiLayout+Layout.m PSEmojiLayout+KBResize.m Tweak.xm
EmojiLayout_USE_SUBSTRATE = 1

include $(THEOS_MAKE_PATH)/tweak.mk
include ../preferenceloader/locatesim.mk

ifeq ($(SIMULATOR),1)
setup:: clean all
	@rm -f /opt/simject/$(TWEAK_NAME).dylib
	@cp -v $(THEOS_OBJ_DIR)/$(TWEAK_NAME).dylib /opt/simject
	@cp -v $(PWD)/$(TWEAK_NAME).plist /opt/simject
	$(ECHO_NOTHING)find $(PWD)/EmojiLayout -name .DS_Store | xargs rm -rf$(ECHO_END)
	@sudo cp -vR $(PWD)/EmojiLayout $(PL_SIMULATOR_PLISTS_PATH)/
else
internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp -R EmojiLayout $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/EmojiLayout$(ECHO_END)
	$(ECHO_NOTHING)find $(THEOS_STAGING_DIR) -name .DS_Store | xargs rm -rf$(ECHO_END)
endif
