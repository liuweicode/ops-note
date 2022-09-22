---
layout: post
title:  Zend Framework 环境搭建与配置
date:   2010-04-30
categories: [PHP]
no-post-nav: true
---

1：首先下载Zend Framework:下载地址：http://www.zendframework.com/download/latest

2：开启PDO：在php.ini文件中把extension=php_pdo.dll之前的“;”号给去掉，并选择性开启相应的数据库组件，我这里用的mysql，所以我将extension=php_pdo_mysql.dll之间的“;”号也去掉了。

3：开启Apache的 rewrite模块，打开httpd.conf 文件，将“LoadModule rewrite_module modules/mod_rewrite.so”前面的#号去掉。

4：打开允许.htaccess的配置的识别，将AllowOverride none 改为 AllowOverride All 。

这是我的配置：

<Directory "E:\IT\php"> 
Options Indexes FollowSymLinks MultiViews 注意：这一句不配置会出现403错误。 
AllowOverride All 单词首字母大写 
Order allow,deny 
Allow from all 
</Directory>

5：下面我们新建一个项目,将下载好的Zend Framework开发包中library下的zend包放在lib目录下。

我们新建一个.htaccess文件
文件内容如下：

RewriteEngine on 
RewriteRule !\.(js|ico|gif|jpg|png|css)$ index.php 

php_flag magic_quotes_gpc off 
php_flag register_globals off

PS：前两行代码表示开启Rewrite引擎，保证了程序的单一入口为index.php. 后两句表示禁用 Magic quotes，即禁止magic_quotes_gpc自动为字符串添加转义字符，因为开启会降低程序的可移植性和影响性能，并且php6已经已经不支持该特性。
6：好了，到此为止前期配置应该差不多了，我们可以打印一下服务器的配置信息，新建一个phpinfo.php文件：

<?php 
phpinfo(); 
?>

运行phpinfo.php，检查相关配置是否成功。
7：新建index.php,配置Zend framework：

<?php 
/* 
* Created on 2010-4-30 By LiuWei 
* 优缘网 
* www.uyvan.com 
*/ 
error_reporting(E_ALL|E_STRICT); 

date_default_timezone_set(‘Asia/Shanghai’); 

set_include_path(‘.’ .PATH_SEPARATOR .’./lib’.PATH_SEPARATOR .’./application/models/’.PATH_SEPARATOR . get_include_path()); //配置环境路径 

require_once "lib/Zend/Loader/Autoloader.php"; //载入zend framework框架类库 
$loader=Zend_Loader_Autoloader::getInstance()->setFallbackAutoloader(true); //自动加载类文件 
$loader->suppressNotFoundWarnings(false); 
$registry = Zend_Registry::getInstance(); //静态获得实例 
$view = new Zend_View(); 
$view->setScriptPath(‘./application/views/’);//设置模板路径 
$registry['view'] = $view; 

//设置控制器 
$frontController =Zend_Controller_Front::getInstance();//前段控制器，在我看来相当于java里面的struts的ActionServlet 
$frontController->setBaseUrl(‘/ZendFramework1′)//设置基本路径 
->setParam(‘noViewRenderer’, true) 
->setControllerDirectory(‘./application/controllers’) 
->throwExceptions(true) 
->dispatch(); 
?>

8：新建控制器，IndexController.php：

<?php 
class IndexController extends Zend_Controller_Action { 

function init() 
{ 
$this->registry = Zend_Registry :: getInstance();//这里获得注册的实例，这里也似乎更java框架struts里面的ActionForm有点类似 
$this->view = $this->registry['view'];//将该实例赋给一个变量 
$this->view->baseUrl = $this->_request->getBaseUrl(); 
} 
function indexAction() {//默认调用该方法处理请求 
//定义一个helloZend变量，并赋值为Hello,Zend Framework 
$this->view->helloZend = ‘Hello,Zend Framework’; 
echo $this->view->render(‘index.html’); //显示模版 
} 
} 
?>

9：新建视图层的页面，index.html

<?php 
echo $this->helloZend; 
?>