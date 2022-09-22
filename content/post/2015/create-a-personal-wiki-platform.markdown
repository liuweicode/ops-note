---
layout: post
title:  "搭建个人知识管理平台"
date:   2015-08-16
categories: [Wiki, Share]

---

## 环境

- ECS 1核/1G/CentOS6.5 x64
- Nginx 1.0.15
- Nodejs v0.12.7
- Forever v0.15.1

## 安装

前期服务器搭建，反向代理设置等已经做好，下面只记录一下Raneto的安装过程。主要是针对自己的喜好，做了一些修改。

### 1.下载 [Raneto](https://github.com/gilbitron/Raneto/releases)   

目前最新版本v0.6.0，下载并解压到网站根目录：

```
wget https://github.com/gilbitron/Raneto/archive/0.6.0.tar.gz
tar -zxvf 0.6.0.tar.gz -C /home/wwwroot/
cd /home/wwwroot/
mv Raneto-0.6.0 liuwei.co
chown www.www liuwei.co -R
```

### 2.修改首页列表宽度全屏

将首页列表宽度改成100%

```
cd /home/wwwroot/liuwei.co
vim public/styles/raneto.css
```
将下面的代码添加到最后:

```
/*将首页列表宽度改成100%*/
.col-sm-4 {
width: 100%;
}
```

### 3.添加中文搜索支持

感谢[nandy007](https://github.com/nandy007/lunr.js)为lunr.js添加了中文搜索的支持，修改package.json：

```
vim package.json
```
找到`dependencies`节点下面的`lunr`模块，如下:

```
"dependencies": {
"body-parser": "~1.0.0",
"cookie-parser": "~1.0.1",
"debug": "~0.7.4",
"express": "~4.2.0",
"extend": "^1.2.1",
"glob": "^4.0.0",
"hogan-express": "^0.5.2",
"lunr": "^0.5.3",
"marked": "^0.3.2",
"moment": "^2.6.0",
"morgan": "~1.0.0",
"raneto-core": "0.x",
"static-favicon": "~1.0.0",
"underscore": "^1.6.0",
"underscore.string": "^2.3.3",
"validator": "^3.13.0"
}
```

替换成下面的代码:

```
"dependencies": {
"body-parser": "~1.0.0",
"cookie-parser": "~1.0.1",
"debug": "~0.7.4",
"express": "~4.2.0",
"extend": "^1.2.1",
"glob": "^4.0.0",
"hogan-express": "^0.5.2",
"lunr": "https://github.com/liuweicode/lunr.js",
"marked": "^0.3.2",
"moment": "^2.6.0",
"morgan": "~1.0.0",
"raneto-core": "0.x",
"static-favicon": "~1.0.0",
"underscore": "^1.6.0",
"underscore.string": "^2.3.3",
"validator": "^3.13.0"
}
```

### 4.安装依赖并forever启动

```
npm install
forever stop bin/www
forever start -e error.log bin/www  
```

### 5.打开浏览器访问
完毕




---

============2015年8月17日 修改================

```
vim views/home.html
```

找到`Main Articles`

修改如下:

```
<div class="panel panel-default {{class}}">
<!-- <h2 class="panel-heading">Main Articles</h2> -->
<h2 class="panel-heading">To be a stronger and better version of myself!</h2>
<ul class="list-group pages">
{{#files}}
<li class="list-group-item page"><a href="/{{slug}}">{{title}}</a></li>
{{/files}}
</ul>
</div>
```

## TODO
- 首页添加日期显示
- 首页添加翻页功能


