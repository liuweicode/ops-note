---
layout: post
title:  Centos6.3 安装VirtualBox
date:   2012-12-02
categories: [Centos,VirtualBox]
no-post-nav: true
---

查看系统信息：

```
[wei@liuwei ~]$ uname -a
Linux liuwei.co 2.6.32-279.14.1.el6.i686 #1 SMP Tue Nov 6 21:05:14 UTC 2012 i686 i686 i386 GNU/Linux
```

从官网（https://www.virtualbox.org/wiki/Linux_Downloads）下载对应的rpm包：

```
wget http://download.virtualbox.org/virtualbox/4.2.4/VirtualBox-4.2-4.2.4_81684_el6-1.i686.rpm
``` 

执行安装：

```
[wei@liuwei temp]$ sudo rpm -ivh VirtualBox-4.2-4.2.4_81684_el6-1.i686.rpm 
[sudo] password for wei: 
warning: VirtualBox-4.2-4.2.4_81684_el6-1.i686.rpm: Header V4 DSA/SHA1 Signature, key ID 98ab5139: NOKEY
Preparing... ########################################### [100%]
1:VirtualBox-4.2 ########################################### [100%]

Creating group 'vboxusers'. VM users must be member of that group!

No precompiled module for this kernel found -- trying to build one. Messages
emitted during module compilation will be logged to /var/log/vbox-install.log.

Stopping VirtualBox kernel modules [确定]
Recompiling VirtualBox kernel modules [失败]
(Look at /var/log/vbox-install.log to find out what went wrong)
```

查看日志信息：

```
[wei@liuwei ~]$ cat /var/log/vbox-install.log
Makefile:181: *** Error: unable to find the sources of your current Linux kernel. Specify KERN_DIR=<directory> and run Make again。 停止。
```

```
[wei@liuwei temp]$ export KERN_DIR=/usr/src/kernels/2.6.18-128.1.10.el5-PAE-i686/
[wei@liuwei temp]$ sudo /etc/init.d/vboxdrv setup
[sudo] password for wei: 
Stopping VirtualBox kernel modules [确定]
Recompiling VirtualBox kernel modules [确定]
Starting VirtualBox kernel modules 
```

打开“应用程序”-“系统工具-“Oracle vm virtualbox”...

参考：
https://www.virtualbox.org/manual/ch02.html#idp6781984
http://blog.chinaunix.net/uid-20424874-id-1947323.html






