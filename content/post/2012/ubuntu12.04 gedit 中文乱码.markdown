---
layout: post
title:  ubuntu12.04 gedit 中文乱码
date:   2012-06-04
categories: [Ubuntu]
no-post-nav: true
---

终端输入：

```
gsettings set org.gnome.gedit.preferences.encodings auto-detected “['UTF-8','GB18030','GB2312','GBK','BIG5','CURRENT','UTF-16']”
```

或者运行gconf-editor命令打开配置编辑器：
在apps > gedit2 > preferences > encodings

修改auto_detected值为：’UTF-8′,’GB18030′,’GB2312′,’GBK’,'BIG5′,’CURRENT’,'UTF-16′。
