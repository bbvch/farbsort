Setup
-----

Checkout:

```
git clone --recurse-submodules git://github.com/ppoile/farbsort
```

Prepare:
```
cd farbsort
source setup-yocto-env.sh
```

Build
-----

Build all in one go:

```
make
```

...or build single targets. Host dependencies:

```
make host-dependencies
```

rootfs:

```
make rootfs
```

SD-Card image:

```
make sdcard-image
```
