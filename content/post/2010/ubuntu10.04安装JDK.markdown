---
layout: post
title:  ubuntu10.04安装JDK
date:   2010-05-15
categories: [Ubuntu,Java,JDK]
no-post-nav: true
---

1. 从sun官方网站下载JDK，我的是jdk-6u20-linux-i586.bin 

[点击去下载 jdk-6u20-linux-i586.bin](https://cds.sun.com/is-bin/INTERSHOP.enfinity/WFS/CDS-CDS_Developer-Site/en_US/-/USD/ViewFilteredProducts-SingleVariationTypeFilter?DLWidget=true&AutoWidgetDL=)

2. 进入到/usr/lib目录下，创建java目录：mkdir java

3. 用mv命令将下载好的文件移动到上一步所创建的java目录中。

4. 修改权限 `sudo chmod u+x /usr/lib/java/jdk-6u20-linux-i586.bin`（chmod命令的参数如下：u 表示该档案的拥有者，g 表示与该档案的拥有者属于同一个群体(group)者，o 表示其他以外的人，a 表示这三者皆是）

5. 输入`sudo ./jdk-6u20-linux-i586.bin` 命令执行安装，相当于windows下的下一步下一步，之类的。

6. 修改环境变量：`sudo gedit /etc/environment` 这是我的设置(红色部分是需要添加的)：

```
PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/lib/java/jdk1.6.0_20/bin"
CLASSPATH="/usr/lib/java/jdk1.6.0_20/lib"
JAVA_HOME="/usr/lib/java/jdk1.6.0_20"
```

7. 执行以下命令，将javac和java命令注册到bin目录下：

```
sudo update-alternatives --install /usr/bin/java java /usr/lib/java/jdk1.6.0_20/bin/java 300

sudo update-alternatives --install /usr/bin/javac javac /usr/lib/java/jdk1.6.0_20/bin/javac 300

sudo update-alternatives --config java
```

–config 这个选项使我们可以选择其中一个命令程序来作为java命令的执行，当然我这里只有sun的jdk，所以不会提示我选择。

8. 至此，jdk差不多安装好了。输入 java -version显示如下：

```
liuwei@IT-liuwei:/usr/lib/java$ java -version
java version "1.6.0_20"
Java(TM) SE Runtime Environment (build 1.6.0_20-b02)
Java HotSpot(TM) Client VM (build 16.3-b01, mixed mode, sharing)
```

9. 这里我们可以vi Test.java 编辑一个java文件，输入内容如下：

```
public class Test{
public static void main(String[] args){
   System.out.print("Hello JDK");
  }
}
```

之后用javac编译，用java执行如下：

```
liuwei@IT-liuwei:~$ javac Test.java
liuwei@IT-liuwei:~$ java Test
Hello JDKliuwei@IT-liuwei:~$
```
