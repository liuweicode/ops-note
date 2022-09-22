---
layout: post
title:  Cannot create a server using the selected type 解决办法
date:   2012-06-04
categories: [Eclipse,Java]
no-post-nav: true
---

Eclipse 新建Tomcat Server出现“Cannot create a server using the selected type”。

1,查看Eclipse绑定的Tomcat installation directory写的是不是Tomcat的路径。

2,删除Eclipse工作目录下 /.metadata/.plugins/org.eclipse.core.runtime/.settings中的org.eclipse.wst.server.core.prefs 和 org.eclipse.jst.server.tomcat.core.prefs文件，重启Eclipse。