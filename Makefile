TARGET := iphone:clang:latest:15.0
ARCHS = arm64

include $(THEOS)/makefiles/common.mk

TOOL_NAME = mount_bindfs umount_bindfs

mount_bindfs_FILES = main.m
mount_bindfs_CFLAGS = -fobjc-arc
mount_bindfs_CODESIGN_FLAGS = -Sentitlements.plist
mount_bindfs_INSTALL_PATH = /usr/local/bin

umount_bindfs_FILES = unmount.m
umount_bindfs_CFLAGS = -fobjc-arc
umount_bindfs_CODESIGN_FLAGS = -Sentitlements.plist
umount_bindfs_INSTALL_PATH = /usr/local/bin

include $(THEOS_MAKE_PATH)/tool.mk
