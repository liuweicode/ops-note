---
layout: post
title:  Ubuntu 图形界面无法登录
date:   2013-02-27
categories: [Server]
no-post-nav: true
---

今天登录ubuntu的时候，在图形界面输入密码，始终登录不进去。网上查原因说不要在/etc/environment里设置export PATH，这样会导致重启后登录不了。我回想今天在安装Maven的时候，在/etc/environment中写了如下内容：

```
#jesse add maven envirment

export M2_HOME=/opt/apache-maven

export M2=$M2_HOME/bin

export MAVEN_OPTS="-Xms256m -Xmx512m"

export PATH=$M2:$PATH
```

于是我ctrl+alt+f1进入命令模式，将以上代码删除，之后重启，问题解决。