ARCHS = armv7 arm64
SDKVERSION = 8.1

include /opt/theos/makefiles/common.mk

TWEAK_NAME = CenterStage
CenterStage_FILES = Tweak.xm
CenterStage_FRAMEWORKS = UIKit

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 backboardd"

SUBPROJECTS += centerstageprefs
include $(THEOS_MAKE_PATH)/aggregate.mk
