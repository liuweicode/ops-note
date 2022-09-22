---
layout: post
title:  ubuntu10.04安装tomcat6
date:   2010-05-16
categories: [Ubuntu,Server]
no-post-nav: true
---

安装tomcat6：

1，下载tomcat：http://tomcat.apache.org/download-60.cgi 我下载的是apache-tomcat-6.0.26.tar.gz

2，将文件移入你要安装的目录：sudo mv apache-tomcat-6.0.26-deployer.tar.gz /usr/local/myserver/ （我习惯的目录是local下面的myserver）

3，进入到你移动到的目录，将文件解压：
sudo gunzip apache-tomcat-6.0.26.tar.gz
sudo tar -xvf apache-tomcat-6.0.26.tar

这里我们解压好之后，寻找类似于README的文件，看到有一个RUNNING.txt文件，差不多就是它了，用cat或者less之类的命令大致浏览一下，果然找到了安装步骤，部分安装说明如下：

(2) Download and Install the Tomcat Binary Distribution
NOTE: As an alternative to downloading a binary distribution, you can create
your own from the Tomcat source repository, as described in “BUILDING.txt”.
If you do this, the value to use for “${catalina.home}” will be the “dist”
subdirectory of your source distribution.
(2.1) Download a binary distribution of Tomcat from:

http://tomcat.apache.org

(2.2) Unpack the binary distribution into a convenient location so that the
distribution resides in its own directory (conventionally named
“apache-tomcat-[version]“). For the purposes of the remainder of this document,
the symbolic name “$CATALINA_HOME” is used to refer to the full
pathname of the release directory.
(3) Start Up Tomcat
(3.1) Tomcat can be started by executing the following commands:
$CATALINA_HOME\bin\startup.bat (Windows)
$CATALINA_HOME/bin/startup.sh (Unix)
(3.2) After startup, the default web applications included with Tomcat will be
available by visiting:

http://localhost:8080/

(3.3) Further information about configuring and running Tomcat can be found in
the documentation included here, as well as on the Tomcat web site:

http://tomcat.apache.org

(4) Shut Down Tomcat
(4.1) Tomcat can be shut down by executing the following command:
$CATALINA_HOME\bin\shutdown (Windows)
$CATALINA_HOME/bin/shutdown.sh (Unix)

好了，继续……

4，将文件夹改名为tomcat6 ：sudo mv apache-tomcat-6.0.26 tomcat6

5，进入到tomcat6目录并执行命令：
cd tomcat6
sudo bin/startup.sh

6，浏览器访问http://localhost:8080/ 看到那只可爱的猫就成功了。。。

7，最后别忘了再看看它的说明书，其他的高级设置等等，RUNNING.txt文件里面也有说明，可以按照需要自己了解研究。