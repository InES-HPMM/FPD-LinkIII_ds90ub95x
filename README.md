# FPD-LinkIII_ds90ub95x
This repository contains an FDP Link III driver for ds90ub954 (deserializer) and ds90ub953 (serializer) from Texas Instruments. The driver was tested on a Jetson Nano (Jetpack 4.4) and on a RaspberryPi 4.

[![logo](https://github.com/InES-HPMM/FPD-LinkIII_Raspberry_HW/blob/master/images/ines_logo.png)](https://www.zhaw.ch/en/engineering/institutes-centres/ines/ "Homepage")

__The group High Performance Multimedia from the Institute of Embedded Systems associated with ZHAW School of Engineering proudly presents an open source driver for TI devices DS90UB954 paired with DS90UB953.__

__Additionally we made a TI FPD-Link III hardware compatible with the Raspberry Pi camera and the Raspberry Pi FFC (FPC, ZIF) camera connector:__
<https://github.com/InES-HPMM/FPD-LinkIII_Raspberry_HW>

> For recent news check out our [Blog](https://blog.zhaw.ch/high-performance/).

## Setup RaspberryPi 4 for FDP-LinkIII_Raspberry_HW

This section gives instructions to setup a RaspberryPi 4 to use the hardware developed in: https://github.com/InES-HPMM/FPD-LinkIII_Raspberry_HW. 

The raspian operating system comes with programs such as raspistill, raspivid and so forth which enables the user to record pictures/videos with the RaspberryPi Camera v2.1 (imx219). But when adding the FPD-Link III driver to the device tree, these programs will no longer work. An alternative way to get images from the camera is by using libcamera (<https://libcamera.org/)>. Libcamera is developed for the linux kernel 5. For this reason, these instructions will use the kernel version 5.4.51.

### Setup SD card
Setup an SD card for the RaspberryPi. The easiest way is to install the Imager software from the official RaspberryPi sources: https://www.raspberrypi.org/downloads/. Run Imager and choose the Operating System **Raspberry Pi OS (32-bit)**, choose your SD card and then press **Write**.

Boot your RaspberryPi with the prepared SD card.

### Update to Kernel 5.4

Connect the RaspberryPi to the internet (ethernet or wifi). Open a terminal an execute the following commands:

```bash
sudo apt update
sudo apt full-upgrade
```

After a reboot, execute:

```bash
sudo rpi-update 8382ece2b30be0beb87cac7f3b36824f194d01e9
sudo reboot
```

(Do not skip this reboot!)

### Add Driver Sources to RaspberryPi

Download `ds90ub954.dtbo`, `ds90ub954.ko`, `imx219.ko` from this repos release onto the RaspberryPi. In the terminal go to the folder with the three downloaded files and copy them to the correct destinations:

```bash
//sudo chmod 777 ds90ub954.dtbo
sudo cp ds90ub954.dtbo /boot/overlays/.
sudo cp ds90ub954.ko /lib/modules/`uname -r`/kernel/drivers/media/i2c/.
//sudo cp imx219.ko /lib/modules/`uname -r`/kernel/drivers/media/i2c/.
```

Get ds90ub954.ko to start at boot by opening `/etc/modules`:

```bash
sudo nano /etc/modules
```

Insert the following line at the bottom of the file:

```bash
ds90ub954
```

Reload module dependencies by running:

```bash
sudo depmod
```

Update `/boot/config.txt`:

```bash
sudo nano /boot/config.txt
```

Add the following lines at the end of the file:

```bash
dtoverlay=ds90ub954
dtoverlay=imx219
core_freq_min=250
```

Reboot the RaspberryPi:

```bash
sudo reboot
```

If the module was successfully loaded, you should find a video0 device in the `/dev` folder:

```bash
ls /dev/video0
```

If the command returns `No such file or directory` then you must reload the imx219 module:

```
sudo rmmod imx219
sudo modprobe imx219
```

Now `/dev/video0` should exist.

### Install libcamera

The follwing steps were taken from <https://www.raspberrypi.org/documentation/linux/software/libcamera/README.md>.

Install software dependencies:

```bash
sudo apt install libboost-dev libgnutls28-dev openssl libtiff5-dev meson qtbase5-dev libqt5core5a libqt5gui5 libqt5widgets5
sudo pip3 install pyyaml
```

Get libcamera sources:

```bash
git clone git://linuxtv.org/libcamera.git
cd libcamera
```

Build libcamera:

```bash
meson build
cd build
meson configure -Dpipelines=raspberrypi -Dtest=false
cd ..
sudo ninja -C build install
```

Run libcamera's qcam:

```
./build/src/qcam/qcam
```


## Insert Driver into your Linux Sources
The driver can be used in different linux kernels and for different hardware setups. We have tested the driver on the RaspberryPi 4, Nvidia Jetson Nano and Nvidia Jetson Xavier. In order to adapt the driver to different hardware setups, the driver provides device tree parameters to set the number of csi lanes, lane speed, gpio control and more. A detailed description can be found in the file `ti,ds90ub954.txt`.

### Insert Driver into Kernel Sources with Git Subtree

An option of adding the driver to the kernel is by using git subtree.

Go into the kernel source folder (`drivers` should be a subfolder) and then add the driver sources with git subtree:

```
git subtree add --prefix drivers/media/i2c/ds90ub95x https://github.com/InES-HPMM/FPD-LinkIII_ds90ub95x master --squash
```

This will make a new folder `ds90ub95x` in `drivers/media/i2c` which includes all the driver files.

### Add the Driver to Makefile and Kconfig

Open the file `drivers/media/i2c/Makefile`:

```bash
nano drivers/media/i2c/Makefile
```

Add the following line to the beginning of the file:

```
obj-$(CONFIG_VIDEO_DS90UB954)	+= ds90ub95x/
```

Open `drivers/media/i2c/Kconfig`:

```bash
nano drivers/media/i2c/Kconfig
```

Add the following line to the beginning of the file:

```
source "drivers/media/i2c/ds90ub95x/Kconfig"
```

After this step, the driver module can be enabled in the menuconfig.


