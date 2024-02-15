# FPD-LinkIII_ds90ub95x
This repository contains an FDP Link III driver for ds90ub954 (deserializer) and ds90ub953 (serializer) from Texas Instruments. The driver was tested on a Jetson Nano (Jetpack 4.4) and on a RaspberryPi 4.

---

[![logo](https://github.com/InES-HPMM/FPD-LinkIII_Raspberry_HW/blob/master/images/ines_logo.png)](https://www.zhaw.ch/en/engineering/institutes-centres/ines/ "Homepage")

__The group High Performance Multimedia from the Institute of Embedded Systems associated with ZHAW School of Engineering proudly presents an open source driver for TI devices DS90UB954 paired with DS90UB953.__

__Additionally we made a TI FPD-Link III hardware compatible with the Raspberry Pi camera  (V2/V3) and the Raspberry Pi FFC (FPC, ZIF) camera connector:__
<https://github.com/InES-HPMM/FPD-LinkIII_Raspberry_HW>

> For recent news check out our [Blog](https://blog.zhaw.ch/high-performance/).

## Table of contents

[Setup RaspberryPi 4 for FDP-LinkIII_Raspberry_HW](#setup-raspberrypi-4-for-fdp-linkiii_raspberry_hw): Instructions to get the FDP-LinkIII Raspberry Hardware running on a RaspberryPi 4 by using our precompiled module.

[Insert Driver into your Linux Sources](#insert-driver-into-your-linux-sources): Instructions on how to get the driver into your custom linux sources.

---

## Setup RaspberryPi 4 for FDP-LinkIII_Raspberry_HW

This section gives instructions to setup a RaspberryPi 4 to use the hardware developed in: https://github.com/InES-HPMM/FPD-LinkIII_Raspberry_HW. 

The raspian operating system comes with programs such as raspistill, raspivid and so forth which enables the user to record pictures/videos with the RaspberryPi Camera v2.1 (imx219) and v3.12 (imx708). But when adding the FPD-Link III driver to the device tree, these programs will no longer work. An alternative way to get images from the camera is by using libcamera (<https://libcamera.org/>). Some libcamera applications are preinstalled in the kernel version 6.1.47. For this reason, these instructions will use the kernel version 6.1.47.

### Setup SD card
Setup an SD card for the RaspberryPi. The easiest way is to install the Imager software from the official RaspberryPi sources: https://www.raspberrypi.org/downloads/. Run Imager and choose **Raspberry Pi OS (other)** and then the Operating System **Raspberry Pi OS (64-bit)**, choose your SD card and then press **Write**.

Boot your RaspberryPi with the prepared SD card.

### Update to Kernel 6.1

Connect the RaspberryPi to the internet (ethernet or wifi). Open a terminal an execute the following commands:

```bash
sudo apt update
sudo apt full-upgrade
```

After a reboot, execute:

```bash
sudo rpi-update b2b3c05f6e9944c2e7eab8648a0cde932e25a31e
sudo reboot
```

(Do not skip this reboot!)

### Add Driver Sources to RaspberryPi

Download `ds90ub954.dtbo` and `ds90ub954.ko` from this release:
 - **Camera module v2.1**: [6.1.47-v8+ for Raspi Cam Module v2.1](https://github.com/InES-HPMM/FPD-LinkIII_ds90ub95x/releases/tag/raspi-6.1.47-v8%2B)
 - **Camera module v3.12**: [6.1.47-v8+ for Raspi Cam module v3.12](https://github.com/InES-HPMM/FPD-LinkIII_ds90ub95x/releases/tag/raspi-6.1.47-v8%2B_camModuleV3.12)

 onto the RaspberryPi. In the terminal go to the folder with the downloaded files and copy them to the correct destinations:

```bash
sudo cp ds90ub954.dtbo /boot/overlays/.
sudo cp ds90ub954.ko /lib/modules/`uname -r`/kernel/drivers/media/i2c/.
```

Get ds90ub954.ko to start at boot by opening `/etc/modules-load.d/modules.conf`:

```bash
sudo nano /etc/modules-load.d/modules.conf
```

Insert the following line at the bottom of the file:

```bash
ds90ub954
```

Reload module dependencies by running:

```bash
sudo depmod
```

Update `/boot/firmware/config.txt`:

```bash
sudo nano /boot/firmware/config.txt
```

Add the following lines at the end of the file:

- **Camera module v2.1:**
  ```bash
  dtoverlay=ds90ub954
  dtoverlay=imx219
  core_freq_min=250
  ```

- **Camera module v3.12:**
  ```bash
  dtoverlay=ds90ub954
  dtoverlay=imx708
  core_freq_min=250
  ```

Reboot the RaspberryPi:

```
sudo reboot
```

If the module was successfully loaded, you should find a video0 device in the `/dev` folder:

```
ls /dev/video0
```

If the command returns `No such file or directory` then the loading of the imx219/imx708 module failed. This can happen when the imx219/imx708 sensor model is loaded before the ds90ub954 module has finished setting up the i2c channel. 

This problem can be solved by reloading the imx219/imx708 module (has to be done again after every reboot):

- **Camera module v2.1:**
  ```bash
  sudo modprobe -r imx219
  sudo modprobe imx219
  ```

- **Camera module v3.12:** (Since the camera module v3 has an autofocus, the driver of the DAC that operates the voice coil must also be reloaded)
  ```bash
  sudo modprobe -r imx708
  sudo modprobe -r dw9807_vcm
  sudo modprobe imx708
  sudo modprobe dw9807_vcm
  ```

Now `/dev/video0` should exist.

### Use libcamera to display video stream

Run the on kernel version 6.1.47-v8+ preinstalled libcamera-vid programm with a Resolution of 1920x1080 for 10 Seconds to stream from camera and display it:

```bash
libcamera-vid --width 1920 --height 1080 -t 10000
```


---

## Insert Driver into your Linux Sources
The driver can be used in different linux kernels and for different hardware setups. We have tested the driver on the RaspberryPi 4 and on a Nvidia Jetson Nano. In order to adapt the driver to different hardware setups, the driver provides device tree parameters to set the number of csi lanes, lane speed, gpio control and more. A detailed description can be found in the file [ti,ds90ub954.txt](https://github.com/InES-HPMM/FPD-LinkIII_ds90ub95x/blob/master/ti%2Cds90ub954.txt).

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

