autostash alias activate='source sources/poky/oe-init-build-env build'
autostash alias copy-image='sudo dd bs=4M if=$(ls /var/tmp/wic/build/sdimage-bootpart-*.direct) of=/dev/mmcblk0'

