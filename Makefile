ARCHS = armv7 arm64

include /opt/theos/makefiles/common.mk

TWEAK_NAME = CenterStage
CenterStage_FILES = Tweak.xm
CenterStage_FRAMEWORKS = UIKit

xxx_CFLAGS=-fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 backboardd"

SUBPROJECTS += centerstageprefs
include $(THEOS_MAKE_PATH)/aggregate.mk
