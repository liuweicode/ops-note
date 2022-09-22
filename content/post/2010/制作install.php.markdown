---
layout: post
title:  制作install.php
date:   2010-04-24
categories: [PHP]
no-post-nav: true
---

很多开源程序如Uchome，Dz，phpwind，thinkSNS等，他们在进行安装的时候都要求执行install.php进行安装，其实执行install.php安装程序的本质就是用程序中配置的数据库结构创建数据库，并初始化数据库，在我看来这个跟Java里面的ORM框架Hibernate将对象模型导入成数据模型有点相似，不过还是有区别的，虽然PHP现在的版本支持OO思想，但它还不是一个完全面向对象的编程语言，好了，接下来我们做一个简单的php install程序。

第一步：新建一个install.php文件

```

<? php
echo "检查文件权限……<br/>";
if (!is_writable("data/config.php")) {
    echo "<font color=red>config.php文件不可写，请检查权限！</font>";
} else {
    echo "<font color=green>config.php文件可写…</font><br/>";
    echo "<button type=submit name=step1 onClick=\"javascript:window.location.href='step1.php'\">下一步</button>";
} ?>

```

注：这里主要针对Linux/Unix等系统下文件权限的判断，windows下默认是可读写的。

第二步，我们配置相关数据库参数，新建step1.php

```

<h3> 填写数据库链接信息 </h3> 
<form action = "step2.php" method = "POST" >
填写主机： <input type = "text" name = "db_host" value = "localhost" /> <br>
用户名： <input type = "text" name = "db_user" value = "root" /> <br>
密码： <input type = "text" name = "db_pass" value = "" / > <br>
数据库名： <input type = "text" name = "db_dbname" value = "uyvandb" /> <br>
数据前缀： <input type = "text" name = "db_tag" value = "u_" /> <br>
<button type = submit name = install > 下一步 </button> </form>

```

第三步：将用户提交的数据写入配置文件，并导入到数据库中，新建step2.php

```

<? php
if (isset($_POST[install])) {

    $config_str = "<?php";
    $config_str. = "\n";
    $config_str. = '$mysql_host = "'.$_POST[db_host].
    '";';
    $config_str. = "\n";
    $config_str. = '$mysql_user = "'.$_POST[db_user].
    '";';
    $config_str. = "\n";
    $config_str. = '$mysql_pass = "'.$_POST[db_pass].
    '";';
    $config_str. = "\n";
    $config_str. = '$mysql_dbname = "'.$_POST[db_dbname].
    '";';
    $config_str. = "\n";
    $config_str. = '$mysql_tag = "'.$_POST[db_tag].
    '";';
    $config_str. = "\n";
    $config_str. = '?>';

    $ff = fopen("data/config.php", "w+");
    $rs = fwrite($ff, $config_str);
    if ($rs) {
        echo "配置成功……<br/>";
        echo "正在连接数据库……<br/>";
        include_once("data/config.php");
        if (!@$link = mysql_connect($mysql_host, $mysql_user, $mysql_pass)) {
            echo "数据库连接失败! 请返回上一页检查连接参数 <a href=step1.php>返回修改</a>";
        } else {
            echo "连接数据库成功……<br/>";
            mysql_query("CREATE DATABASE `$mysql_dbname`");
            echo "数据库创建成功……<br/>";
            echo "执行导入……<br/>";
            mysql_select_db($mysql_dbname);
            $sql_query[] = "CREATE TABLE IF NOT EXISTS `".$mysql_tag.
            "message1` (
            `id`
            tinyint(1) NOT NULL auto_increment,
                `user`
            varchar(25) NOT NULL,
                `title`
            varchar(50) NOT NULL,
                `content`
            tinytext NOT NULL,
            `lastdate`
            date NOT NULL,
            PRIMARY KEY(`id`)
        ) ENGINE = InnoDB DEFAULT CHARSET = gbk AUTO_INCREMENT = 10;
        ";
        $sql_query[] = "CREATE TABLE IF NOT EXISTS `".$mysql_tag.
        "message2` (
        `id`
        tinyint(1) NOT NULL auto_increment,
            `user`
        varchar(25) NOT NULL,
            `title`
        varchar(50) NOT NULL,
            `content`
        tinytext NOT NULL,
        `lastdate`
        date NOT NULL,
        PRIMARY KEY(`id`)
    ) ENGINE = InnoDB DEFAULT CHARSET = gbk AUTO_INCREMENT = 10;
    ";
    $sql_query[] = "CREATE TABLE IF NOT EXISTS `".$mysql_tag.
    "message3` (
    `id`
    tinyint(1) NOT NULL auto_increment,
        `user`
    varchar(25) NOT NULL,
        `title`
    varchar(50) NOT NULL,
        `content`
    tinytext NOT NULL,
    `lastdate`
    date NOT NULL,
    PRIMARY KEY(`id`)
) ENGINE = InnoDB DEFAULT CHARSET = gbk AUTO_INCREMENT = 10;
";
foreach($sql_query as $val) {
    mysql_query($val);
}
echo "导入成功……<br/>";
echo "安装完成……<br/>";
echo "<button type=submit name=step1 onClick=\"javascript:window.location.href='index.php'\">点击进入主页</button>";
rename("install.php", "install.lock");
}

} else {
    echo "文件配置失敗，请重试……";
}
} ?>

```

最后记提醒用户删除安装文件，或者将安装文件改名.





