---
layout: post
title:  ubuntu 安装dict-xdict出现错误的解决办法
date:   2010-05-06
categories: [Ubuntu]
no-post-nav: true
---

我在安装dict-xdict出现了以下错误：

```
liuwei@IT-liuwei:~$ sudo aptitude install dict-xdict
[sudo] password for liuwei:
正在读取软件包列表… 完成
正在分析软件包的依赖关系树
正在读取状态信息… 完成
正在读取扩展状态文件
正在初始化软件包状态… 完成
正在编辑扩展状态信息… 完成
将不会安装，升级或者删除任何软件包。
0 个软件包被升级，新安装 0 个， 0 个将被删除， 同时 0 个将不升级。
需要获取 0B/3,555kB 的存档。 解包后将要使用 0B。
正在编辑扩展状态信息… 完成
选中了曾被取消选择的软件包 dict-xdict。
(正在读取数据库 … 系统当前总共安装有 127684 个文件和目录。)
正预备替换 dict-xdict 0.1-4 (使用 …/dict-xdict_0.1-4_all.deb) …
正在解压缩将用于更替的包文件 dict-xdict …
正在设置 dict-xdict (0.1-4) …
invoke-rc.d: unknown initscript, /etc/init.d/dictd not found.
dpkg：处理 dict-xdict (–configure)时出错：
子进程 已安装的 post-installation 脚本 返回了错误号 100
在处理时有错误发生：
dict-xdict
E: Sub-process /usr/bin/dpkg returned an error code (1)
软件包安装失败。正在试图恢复：
正在设置 dict-xdict (0.1-4) …
invoke-rc.d: unknown initscript, /etc/init.d/dictd not found.
dpkg：处理 dict-xdict (–configure)时出错：
子进程 已安装的 post-installation 脚本 返回了错误号 100
在处理时有错误发生：
dict-xdict
正在读取软件包列表… 完成
正在分析软件包的依赖关系树
正在读取状态信息… 完成
正在读取扩展状态文件
正在初始化软件包状态… 完成
正在编辑扩展状态信息… 完成
```

之后安装其他软件也相应得出现了如下错误：
E: dict-xdict: 子进程 已安装的 post-installation 脚本 返回了错误号 100

可恶的是我用sudo aptitude purge dict-xdict命令卸载都无法卸载。

用新立德删除也出现了错误提示框.
网上有人说“新力得安装dictd就行了”，地址如下：http://forum.ubuntu.org.cn/viewtopic.php?f=77&t=236661&start=0

但这个方法对我似乎没有效果，我的解决办法是：

进入/etc/init.d/目录下创建dictd文件，然后执行sudo aptitude purge dict-xdict成功删除掉了dict-xdict,之后再安装就不会出现问题了。
如下所示：

```
liuwei@IT-liuwei:~$ cd /etc/init.d/
liuwei@IT-liuwei:/etc/init.d$ sudo touch dictd
liuwei@IT-liuwei:/etc/init.d$ sudo aptitude purge dict-xdict
正在读取软件包列表… 完成
正在分析软件包的依赖关系树
正在读取状态信息… 完成
Reading extended state information
Initializing package states… 完成
The following packages will be REMOVED:
dict-xdict{p}
0 packages upgraded, 0 newly installed, 1 to remove and 33 not upgraded.
Need to get 0B of archives. After unpacking 5,554kB will be freed.
Do you want to continue? [Y/n/?] y
Writing extended state information… 完成
(正在读取数据库 … 系统当前总共安装有 127415 个文件和目录。)
正在删除 dict-xdict …
正在清除 dict-xdict 的配置文件 …
正在读取软件包列表… 完成
正在分析软件包的依赖关系树
正在读取状态信息… 完成
Reading extended state information
Initializing package states… 完成
Writing extended state information… 完成
```