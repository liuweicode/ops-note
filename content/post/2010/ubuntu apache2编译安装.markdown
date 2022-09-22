---
layout: post
title:  ubuntu apache2编译安装
date:   2010-05-10
categories: [Ubuntu,Server]
no-post-nav: true
---

1. 下载源码包: http://httpd.apache.org/download.cgi#apache22 （我下载的是httpd-2.2.15.tar.gz）

2. 解压: tar -zxvf httpd-2.2.15.tar.gz
（ -z, –gzip, –gunzip, –ungzip 通过 gzip 过滤归档
-x, –extract, –get 从归档中解出文件
-v, –verbose 详细地列出处理的文件
-f, –file=ARCHIVE 使用归档文件或 ARCHIVE 设备）

3. 进入目录: cd httpd-2.2.15

4. 收集相关信息,生成makefile文件: sudo ./configure –prefix=/usr/local/myserver/apache2 –enable-module=so
5. 将源码包生成二进制的包: sudo make
6. 安装到指定目录: sudo make install

7. 安装完毕之后，用"ps -ef |grep apache2"命令看有没有启动，如果没有用"sudo /usr/local/myserver/apache2/bin/httpd -k start"命令启动～

如果出现以下错误：

```
liuwei@IT-liuwei:/usr/local/myserver/apache2$ sudo /usr/local/myserver/apache2/bin/httpd -k start
httpd: Could not reliably determine the server’s fully qualified domain name, using 127.0.1.1 for ServerName
```

则用修改httpd.conf文件，在"#ServerName www.example.com:80"这一行下面添加一句"ServerName 127.0.0.1:80"。

再次启动如下:

```
liuwei@IT-liuwei:/usr/local/myserver/apache2$ sudo /usr/local/myserver/apache2/bin/httpd -k start
httpd (pid 2000) already running
liuwei@IT-liuwei:/usr/local/myserver/apache2$ ps -ef |grep apache2
root 2000 1 0 17:15 ? 00:00:00 /usr/local/myserver/apache2/bin/httpd -k start
daemon 2001 2000 0 17:15 ? 00:00:00 /usr/local/myserver/apache2/bin/httpd -k start
daemon 2002 2000 0 17:15 ? 00:00:00 /usr/local/myserver/apache2/bin/httpd -k start
daemon 2003 2000 0 17:15 ? 00:00:00 /usr/local/myserver/apache2/bin/httpd -k start
daemon 2004 2000 0 17:15 ? 00:00:00 /usr/local/myserver/apache2/bin/httpd -k start
daemon 2005 2000 0 17:15 ? 00:00:00 /usr/local/myserver/apache2/bin/httpd -k start
liuwei 2024 1904 0 17:19 pts/1 00:00:00 grep –color=auto apache2
```

8. 打开浏览器输入http://127.0.0.1 显示it works 则安装成功。


