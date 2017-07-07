# Intro

**farbsort** or as it is also known the **AMP Showcase** is a project with the intent to display [bbv's](https://www.bbv.ch) profiency at implementing an embedded solution with real-time conditions on an AMP Board. The first version (July 2017) runs on a beagleboard black. 

![System setup](/home/bernedom/Code/farbsort/doc/images/system_overview.jpg  "The AMP Showcase")

There are several sub-projects/applications needed to run the showcase (all added as git submodules to this repo)

 * *[pru-farbsort](https://github.com/bbvch/pru-farbsort)*: the embedded code 
 * *[farbsort-websocket](https://github.com/bbvch/farbsort-websocket)*: The webocket server that communicates the state of the hardware to any client
 * *[farbsort-gui](https://github.com/bbvch/farbsort-gui)*: the client software to display a nice UI using QML
 * *[meta-farbsort](https://github.com/bbvch/farbsort-meta)*: A bitbake project to create SD  card images for the farbsort board
 
![Applications overview](/home/bernedom/Code/farbsort/doc/images/application_overview.png  "applications overview")

# Setup

Checkout:

```
git clone --recurse-submodules https://github.com/bbvch/farbsort.git
```

Update:
```
git pull
git submodule update --recursive --remote
```

Prepare:
```
cd farbsort
source setup-yocto-env.sh
```

## Build


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
