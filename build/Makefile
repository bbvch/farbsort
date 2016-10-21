.PHONY: all host-dependencies image sdcard-image

all: host-dependencies rootfs sdcard-image

host-dependencies:
	bitbake parted-native mtools-native dosfstools-native

rootfs:
	bitbake farbsort-image-dev

sdcard-image:
	wic create sdimage-bootpart -e farbsort-image-dev
