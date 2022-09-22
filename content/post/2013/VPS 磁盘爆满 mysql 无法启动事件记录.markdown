---
layout: post
title:  VPS 磁盘爆满 mysql 无法启动事件记录
date:   2013-03-16
categories: [VPS]
no-post-nav: true
---

前两天在修改网站图片的时候，发现ftp无法上传，提示磁盘爆满，不会吧，我带着疑惑ssh到vps上，`df -h`查看，果然使用了100%。我想可能是我长时间没有重启vps了，产生了大量的临时文件，于是我reboot vps，结果发现不但问题没有解决，连mysql也无法启动了！service mysql status，显示“MySQL is running but PID file is not found”。

百度谷歌，有人说修改了主机的hostname，好吧，我承认前几天我改过hostname，于是我又将hostname改回来并重启，问题依旧，我想问题需要一个一个解决，应该是磁盘不足的原因，于是我开始排查大文件find / -size +1G，没有找到大于1G的文件。于是又缩小范围find / -size +50M ，最后还是没有发现异常，无果。我继续百度谷歌，有人说mysql的日志文件过大导致，于是去/usr/local/mysql/var/下查看，果然有很多类似“mysql-bin.0000* ”的文件。于是我全部remove掉并重启，依然无效。

继续百度谷歌，最终参考如下文章解决：http://hi.baidu.com/hovlj_1130/item/a7029bf36691d2d443c36a2d
另外由于mysql的日志文件增长过快，导致磁盘开销过大，可以将其关闭：

```
/usr/local/mysql/bin/mysql -u root -p
reset master
exit
vim /etc/my.cnf
```

将以下两行代码前面用#号注释，之后重启mysql.

```
log-bin=mysql-bin
binlog_format=mixed
```