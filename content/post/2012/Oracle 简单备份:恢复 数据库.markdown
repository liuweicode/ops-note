---
layout: post
title:  Oracle 简单备份/恢复 数据库
date:   2012-05-31
categories: [Oracle,数据库]
no-post-nav: true
---

项目中需要将正式库上的数据导入到测试库上，该数据库不知道谁安装的，环境变量都没有设置！%￥#&×%……

我先ssh到测试机上执行如下命令：

```
export ORACLE_HOME=/u01/app/oracle/product/11.1.0/db_1

export ORACLE_SID=ekp

/u01/app/oracle/product/11.1.0/db_1/bin/exp test/password owner=ekpj file=backup0531.dmp log=backup0531.log buffer=6000000
```

之后将文件拷贝到测试机上：

```
scp backup0531.dmp oa@10.0.0.224:/u01/
```

拷贝完成，删除测试机上当前用户下的所有表/视图/序列/函数/存储过程/包：

```
–delete tables
select ‘drop table ‘ || table_name ||’;'||chr(13)||chr(10) from user_tables;

–delete views
select ‘drop view ‘ || view_name||’;'||chr(13)||chr(10) from user_views;

–delete sequence
select ‘drop sequence ‘ || sequence_name||’;'||chr(13)||chr(10) from user_sequences;

–delete functions
select ‘drop function ‘ || object_name||’;'||chr(13)||chr(10) from user_objects where object_type=’FUNCTION’;

–delete procedures
select ‘drop procedure ‘ || object_name||’;'||chr(13)||chr(10) from user_objects where object_type=’PROCEDURE’;

–delete package
select ‘drop package ‘ || object_name||’;'||chr(13)||chr(10) from user_objects where object_type=’PACKAGE’;
```

执行导入命令：

```
/u01/app/oracle/product/11.1.0/db_1/bin/imp test/password file=backup0531.dmp full=y ignore=n
```



