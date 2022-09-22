---
layout: post
title:  Android device chooser unknown
date:   2012-11-15
categories: [Android]
no-post-nav: true
---

当我用真机USB连接电脑时，出现如下图错误，Eclipse无法识别。

![image](https://static.liuwei.co/20121115/device_chooser_unknown_2.png)

解决办法参照：http://developer.android.com/tools/device.html#setting-up

由于我的是Ubuntu系统，手机是摩托罗拉Me722,所以解决办法如下：
sudo vim /etc/udev/rules.d/51-android.rules
把 SUBSYSTEM=="usb", ATTR{idVendor}=="22b8", MODE="0666" 粘贴进去。
接着改变权限：sudo chmod a+r /etc/udev/rules.d/51-android.rules

如果还不行，则使用如下办法，参考：http://stackoverflow.com/questions/5584976/android-device-chooser-my-device-seems-offline
1，Restart adb by issuing 'adb kill-server' followed by 'adb start-server' at a cmd prompt
2，Disable and re-enable USB debugging on the phone
3，Rebooting the phone if it still doesn't work.

由于经常出现无法访问，故记录在此：
Company	USB Vendor ID
Acer 0502
ASUS 0b05
Dell 413c
Foxconn 0489
Fujitsu 04c5
Fujitsu Toshiba 04c5
Garmin-Asus 091e
Google 18d1
Hisense 109b
HTC 0bb4
Huawei 12d1
K-Touch 24e3
KT Tech 2116
Kyocera 0482
Lenovo 17ef
LG 1004
Motorola 22b8
NEC 0409
Nook 2080
Nvidia 0955
OTGV 2257
Pantech 10a9
Pegatron 1d4d
Philips 0471
PMC-Sierra 04da
Qualcomm 05c6
SK Telesys 1f53
Samsung 04e8
Sharp 04dd
Sony 054c
Sony Ericsson 0fce
Teleepoch 2340
Toshiba 0930
ZTE 19d2
