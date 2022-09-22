---
layout: post
title:  编译和安装Apache Http Server
date:   2013-03-16
categories: [VPS]
no-post-nav: true
---

编译安装apr
./configure --prefix=/usr/local/apr
make && make install

编译安装apr-util
./configure --prefix=/usr/local/apr-util 
make && make install

编译安装pcre
./configure --prefix=/usr/local/pcre
出现 configure: error: You need a C++ compiler for C++ support
解决办法：sudo apt-get install g++
然后继续：
./configure --prefix=/usr/local/pcre
make && make install

最后编译安装Apache HTTP Server
./configure --prefix=/usr/local/apache \
--with-included-apr=/usr/local/apr \
--with-apr-util=/usr/local/apr-util \
--with-pcre=/usr/local/pcre

需要哪些模块功能可参考http://httpd.apache.org/docs/2.4/programs/configure.html

sudo gedit /usr/local/apache/conf/httpd.conf
在“#ServerName www.example.com:80”下面添加一行如下：
ServerName 127.0.0.1:80

/usr/local/apache/bin/apachectl -k start

打开浏览器输入：http://127.0.1.1/
出现 It works!

参考：
http://httpd.apache.org/docs/2.4/install.html