ARCHS = armv7 arm64

include /opt/theos/makefiles/common.mk

BUNDLE_NAME = centerstageprefs
centerstageprefs_FILES = centerstageprefs.mm
centerstageprefs_INSTALL_PATH = /Library/PreferenceBundles
centerstageprefs_FRAMEWORKS = UIKit
centerstageprefs_PRIVATE_FRAMEWORKS = Preferences
centerstagprefs_CFLAGS=-fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/centerstageprefs.plist$(ECHO_END)
