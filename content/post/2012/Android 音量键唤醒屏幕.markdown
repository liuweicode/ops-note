---
layout: post
title:  Android 音量键唤醒屏幕
date:   2012-12-14
categories: [Android]
no-post-nav: true
---

```
liuwei@IT:~$ adb shell
/ # cd /system/usr/keylayout
/system/usr/keylayout # ls
AVRCP.kl
Generic.kl
Vendor_045e_Product_028e.kl
Vendor_046d_Product_c216.kl
Vendor_046d_Product_c294.kl
Vendor_046d_Product_c299.kl
Vendor_046d_Product_c532.kl
Vendor_054c_Product_0268.kl
Vendor_05ac_Product_0239.kl
Vendor_22b8_Product_093d.kl
gpio-keys.kl
qwerty.kl
s3c-keypad.kl
/system/usr/keylayout # vi s3c-keypad.kl
```

修改相应的映射的值就好了。
key 42 VOLUME_UP WAKE
key 58 VOLUME_DOWN WAKE

参考：
http://xiaoxia.de/2011/06/change-key-layout-on-android/
http://source.android.com/tech/input/key-layout-files.html