---
layout: post
title:  Zend Framework 数据库连接
date:   2010-05-02
categories: [Ubuntu]
no-post-nav: true
---

Zend_Db_Adapter是zendfrmaeword的数据库抽象层api. 基于pdo, 你可以使用 Zend_Db_Adapter 连接和处理多种 数据库,包括:microsoft SQL Server,MySql,SQLite等等.

链接数据库方法一：要针对不同的数据库实例化一个 Zend_Db_Adapter 对象, 需要 将adapter的名字和描述数据库连接的参数数组作为参数，静态调用 Zend_Db::factory()方法。例如，连接到一个数据库名称为 “camelot”，用户名为“malory”的本地mysql数据库，可以进行如下操作: 

```
<?php 
require_once ‘Zend/Db.php’; 
$params = array (‘host’ => ’127.0.0.1′, 
‘username’ => ‘malory’, 
‘password’ => ‘******’, 
‘dbname’ => ‘camelot’); 
$db = Zend_Db::factory(‘PDO_MYSQL’, $params); 
?>
```

链接数据库方法二（推荐）：将配置信息写在“.ini”结尾的配置文件中（当然你也可以在xml格式的文件中进行配置，这里介绍ini格式文件的配置），INI 格式在提供拥有配置数据键的等级结构和配置数据节之间的继承能力方面具有专长。配置数据等级结构通过用点或者句号 (.)分离键值。一个节可以扩展或者通过在节的名称之后带一个冒号(:)和被继承的配置数据的节的名称来从另一个节继承。如下面的config.ini

```
db.adapter=PDO_MYSQL 
db.config.host=localhost 
db.config.username=malory 
db.config.password=****** 
db.config.dbname=camelot
```

之后调用如下语句，指定数据库Adapter来建立数据库链接：

```
$config=new Zend_Config_Ini(‘./application/config/config.ini’,null, true); 
Zend_Registry::set(‘config’,$config); 
$dbAdapter=Zend_Db::factory($config->general->db->adapter,$config->general->db->config->toArray()); 
$dbAdapter->query(‘SET NAMES GBK’); 
Zend_Db_Table::setDefaultAdapter($dbAdapter); 
Zend_Registry::set(‘dbAdapter’,$dbAdapter);
```

这里的Zend_Config_Ini类，允许开发者通过嵌套的对象属性语法在应用程序中用熟悉的 INI 格式存储和读取配置数据。

$dbAdapter=Zend_Db::factory($config->general->db->adapter,$config->general->db->config->toArray());这一句创建数据库适配器，里面的两个参数分表表示：$config->general->db->adapter取出的值就是上面config.ini文件配置的PDO_MYSQL，而$config->general->db->config->toArray()这一句则将host，username，password，dbname作为数组的形式。Zend_Db_Table::setDefaultAdapter($dbAdapter);这一句设置表的默认适配器，除非你特别指定，否则所有的zend_db_table类实例都会使用 默认adapter。Zend_Registry::set(‘dbAdapter’,$dbAdapter);则是在注册Adapter，Zend_Registry，对象注册表（或称对象仓库）是一个用于在整个应用空间（application space）内存储对象和值的容器。通过把对象存储在其中，我们可以在整个项目的任何地方使用同一个对象。这种机制相当于一种全局存储.我们可以通过Zend_Registry类的静态方法来使用对象注册表，另外，由于该类是一个数组对象，你可以使用数组形式来访问其中的类方法，例如：$value = Zend_Registry::get(‘dbAdapter’);





