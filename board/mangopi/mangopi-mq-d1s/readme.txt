MangoPi MQ D1s (RISC-V)
=======================

MangoPi MQ D1s (board model MQ1W) is a tiny (4x4cm) RISC-V based single board computer. It's built around
Allwinner D1s (also referred as F133) single core 1GHz CPU with integrated 64MB DDR2 RAM.
Board features:
- USB-OTG Type-C socket
- USB-HOST Type-C socket
- 2x 22 pin GPIO headers
- TF card slot
- RTL8189FTV WiFi module with ext. antenna connector
- 15 pin DSI FPC connector
- 40 pin RGB FPC connector
- 6 pin CTP FPC connector
- 24 pin DVP FPC connector
- onboard mic
- onboard audio amplifier
- FEL,reset button

There is no HDMI connector.

How to build
============

$ make mangopi_mangopi_mq_d1s_defconfig
$ make

Wifi
==========

Edit  board/mangopi/mangopi-mq-d1s/overlay/etc/wpa_supplicant.conf or
/etc/wpa_supplicant.conf once connected to the board:

* Replace YOURSSID with your AP ssid
* Replace YOURPASSWD with your AP password

How to write the SD card
========================

Once the build process is finished you will have an image called "sdcard.img"
in the output/images/ directory.

Copy the bootable "sdcard.img" onto an SD card with "dd":

  $ sudo dd if=output/images/sdcard.img of=/dev/sdX

Connect a TTL UART to the UART3 on P8 header (unpopulated), insert the microSD card and
plug in a USB-C cable to the OTG or HOST connector to boot the system.
