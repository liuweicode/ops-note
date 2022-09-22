---
layout: post
title:  ubuntu10.04下mysql编译安装
date:   2010-05-06
categories: [Ubuntu,数据库]
no-post-nav: true
---

1. 首先下 载mysql源码，我下载得是mysql5.0.90版本。

2. 解压：

```
tar -xzvf mysql-5.0.90.tar.gz
```

3. 进入目录：

```
cd mysql-5.0.90
```

4. 收集相关信息，生成makefile：

```
./configure –prefix=/usr/local/mysql （这里我安装在/usr/local/mysql目录下面）
```

configure的时候如果出现了以下错误（没有出错则不用管）：

```
checking for tgetent in -ltermcap… no
checking for termcap functions library… configure: error: No curses/termcap library found
```

说明 curses/termcap 库没有安装，那么运行`apt-cache search curses | grep libncurses`命令，查找相关 得最新得安装包：

我查找得结果如下：

```
liuwei@IT-liuwei:~$ apt-cache search curses | grep libncurses
libncurses5-dbg – debugging/profiling libraries for ncurses
libncurses5-dev – developer’s libraries and docs for ncurses
libncursesw5-dbg – debugging/profiling libraries for ncurses
libncursesw5-dev – developer’s libraries for ncursesw
libncurses5 – 终端控制的共享库
libncursesw5 – shared libraries for terminal handling (wide character support)
libncurses-ruby1.8 – ruby Extension for the ncurses C library
libncurses-ruby1.9.1 – ruby Extension for the ncurses C library
libncurses-ruby – ruby Extension for the ncurses C library
那么我运行“sudo apt-get install libncurses5-dev”命令安装 libncurses5-dev。
安装完成之后，再次运行./configure –prefix=/usr/local/mysql，一切正常。
```

5. 接着将源码包生成二进制的包使用make命令：make

出现了如下错误：

```
../depcomp: line 512: exec: g++: not found
make[2]: *** [my_new.o] Error 127
make[2]: Leaving directory `/usr/local/src/mysql-5.0.90/mysys’
make[1]: *** [all-recursive] Error 1
make[1]: Leaving directory `/usr/local/src/mysql-5.0.90′
make: *** [all] Error 2
```

说明没有安装g++，解决办法同上，这里我用如下命令安装：

```
sudo apt-get install g++
```

安装完成之后再次编译make，又出现如下错误:

```
../include/my_global.h:909: error: redeclaration of C++ built-in type `bool’
make[2]: *** [my_new.o] Error 1
make[2]: Leaving directory `/home/tools/mysql-5.0.90/mysys’
make[1]: *** [all-recursive] Error 1
make[1]: Leaving directory `/home/tools/mysql-5.0.90′
make: *** [all] Error 2
```

是因为g++，c++是在configure之后安装的，此时只需重新configure后再编译make，问题解决。

6. 接下来将makefile文件安装在相应的目录下：

```
make install
```

7. 接下来将support-files下得my-medium.cnf文件拷贝到/etc/my.cnf文件中：

```
sudo cp support-files/my-medium.cnf /etc/my.cnf
```

8. 进入安装目录：cd /usr/local/mysql 用mysql用户初始化数据库：bin/mysql_install_db – -user=mysql
这里一定要用mysql用户，没有的话用下面两个命令创建：

```
sudo groupadd mysql
sudo useradd -g mysql mysql
```

9. 接下来进行一些权限设置：

```
sudo chown -R root .
sudo chown -R mysql var
sudo chgrp -R mysql .
```

10. 启动mysql：bin/mysqld_safe –user=mysql &

如果你要让开机自动启动可以对/etc/rc.local文件进行编辑:

```
vi /etc/rc.local
```

在exit 0前面加上

```
/usr/local/mysql/bin/mysqld_safe --user=mysql &
```

11. 好了，到这里基本上安装完成了，用/usr/local/mysql/bin/mysql登录mysql：

```
liuwei@IT-liuwei:/usr/local/mysql/bin$ /usr/local/mysql/bin/mysql
Welcome to the MySQL monitor. Commands end with ; or \g.
Your MySQL connection id is 2
Server version: 5.0.90-log Source distribution

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql>
```

如果连接不上mysql，您可以在终端提示符后运行以下命令来检查mysql服务器是否正在运行：

```
sudo netstat -tap | grep mysql
```

这是我得显示结果，说明正常运行：

```
liuwei@IT-liuwei:/usr/local/mysql/bin$ sudo netstat -tap | grep mysql
tcp 0 0 *:mysql *:* LISTEN 2121/mysqld
```

这里我们最好设置以下管理员密码：
为了安全，修改root密码：

```
mysql>use mysql
mysql>UPDATE user SET password=PASSWORD('你得密码') WHERE user='root';
mysql>FLUSH PRIVILEGES;
mysql>exit;
```
