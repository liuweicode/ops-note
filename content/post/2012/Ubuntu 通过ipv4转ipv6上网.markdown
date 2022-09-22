---
layout: post
title:  Ubuntu 通过ipv4转ipv6上网
date:   2012-12-04
categories: [Ubuntu,ipv4,ipv6]
no-post-nav: true
---

```
sudo apt-get install miredo
sudo gedit /etc/hosts
```
将如下网址的内容粘贴进去：
https://ipv6-hosts.googlecode.com/hg/hosts

```
sudo gedit /etc/default/ufw
```

修改：IPV6=yes
重启防火墙
sudo ufw disable
sudo ufw enable

参考：https://wiki.ubuntu.com/IPv6#Get_connected_with_Miredo