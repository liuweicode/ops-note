---
layout: post
title:  Centos ntfs-3g 挂载ntfs移动盘
date:   2012-12-02
categories: [Centos,VirtualBox]
no-post-nav: true
---

首先到官网下载源码包
http://www.tuxera.com/community/ntfs-3g-download/

```
tar -zxvf ntfs-3g_ntfsprogs-2012.1.15.tgz
cd ntfs-3g_ntfsprogs-2012.1.15
./configure
```
提示如下：

```
[wei@liuwei ntfs-3g_ntfsprogs-2012.1.15]$ ./configure 
checking build system type... i686-pc-linux-gnu
checking host system type... i686-pc-linux-gnu
checking target system type... i686-pc-linux-gnu
checking for a BSD-compatible install... /usr/bin/install -c
checking whether build environment is sane... yes
checking for a thread-safe mkdir -p... /bin/mkdir -p
checking for gawk... gawk
checking whether make sets $(MAKE)... yes
checking whether to enable maintainer-specific portions of Makefiles... no
checking for gcc... no
checking for cc... no
configure: error: no acceptable C compiler found in $PATH
See `config.log' for more details.
```

提示安装gcc

```
sudo yum install gcc
```

安装成功后再次检查 ./configure 没有问题

```
......
config.status: creating src/ntfs-3g.usermap.8
config.status: creating src/ntfs-3g.secaudit.8
config.status: creating config.h
config.status: executing depfiles commands
You can type now 'make' to build ntfs-3g.
```

执行编译和安装

```
make
sudo make install
```

到此安装成功。

现在将移动盘的usb连接至电脑，执行

```
sudo fdisk -l
```

如下：
.......
Device Boot Start End Blocks Id System
/dev/sdb1 1 60802 488384032+ 7 HPFS/NTFS
接下来挂载移动硬盘：

```
sudo mkdir /mnt/File
sudo mount -t ntfs-3g /dev/sdb1 /mnt/File
```

参考站点：
http://www.ha97.com/2832.html
http://www.tuxera.com/community/ntfs-3g-download/


