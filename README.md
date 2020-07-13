# FPD-LinkIII_ds90ub95x
This repository contains an FDP Link III driver for ds90ub954 (deserializer) and ds90ub953 (serializer) from Texas Instruments. The driver was tested on a Jetson Nano (Jetpack 4.4) and on a RaspberryPi 4.

[![logo](https://github.com/InES-HPMM/FPD-LinkIII_Raspberry_HW/blob/master/images/ines_logo.png)](https://www.zhaw.ch/en/engineering/institutes-centres/ines/ "Homepage")

__The group High Performance Multimedia from the Institute of Embedded Systems associated with ZHAW School of Engineering proudly presents an open source driver for TI devices DS90UB954 paired with DS90UB953.__

__Additionally we made a TI FPD-Link III hardware compatible with the Raspberry Pi camera and the Raspberry Pi FFC (FPC, ZIF) camera connector:__
<https://github.com/InES-HPMM/FPD-LinkIII_Raspberry_HW>

> For recent news check out our [Blog](https://blog.zhaw.ch/high-performance/).

## Add driver to your linux sources
### Option 1: Using Git Subtree
- Open terminal and go into kernel folder of your sources. Then add the driver with subtree:
```
git subtree add --prefix drivers/media/i2c/ds90ub95x https://github.com/InES-HPMM/FPD-LinkIII_ds90ub95x master --squash
```
- Add the following line in the file `drivers/media/i2c/Makefile`:
```
obj-$(CONFIG_VIDEO_DS90UB954)	+= ds90ub95x/
```
- Add the following line in the file `drivers/media/i2c/Kconfig`:
```
source "drivers/media/i2c/ds90ub95x/Kconfig"
```
### Option 2: Copy Driver into your sources
- Clone the repository and copy all the files from the repo into the folder `driver/media/i2c/ds90ub95x`.
- Add the following line in the file `drivers/media/i2c/Makefile`:
```
obj-$(CONFIG_VIDEO_DS90UB954)	+= ds90ub95x/
```
- Add the following line in the file `drivers/media/i2c/Kconfig`:
```
source "drivers/media/i2c/ds90ub95x/Kconfig"
```

