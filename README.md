Setup
-----

Checkout:

```
git clone --recurse-submodules git://github.com/ppoile/farbsort
```

Prepare:
```
cd farbsort
. sources/poky/oe-init-build-env build
```

Build
-----

Build native dependencies:

```
bitbake parted-native mtools-native dosfstools-native
```

Build rootfs:

```
bitbake farbsort-image-dev
```

Create SD-Card image:

```
wic create sdimage-bootpart -e farbsort-image-dev
```
