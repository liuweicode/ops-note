+++
title = "MySQL 备份与还原"
author = "liuwei"
date = "2022-10-26"
tags = [
    "备份",
    "数据库",
]
categories = [
    "mysql",
]
+++

## 一、备份数据

1. 导出db1、db2两个数据库的所有数据。(启用gzip压缩)

```
mysqldump --host=127.0.0.1 --port=3306 --user=root --password --hex-blob --set-gtid-purged=OFF --single-transaction --flush-logs --quick --databases db1 db2 | gzip > db12.sql.gz
```

2. 导出db1库的t1和t2表。(启用gzip压缩)

```
mysqldump --host=127.0.0.1 --port=3306 --user=root --password --hex-blob --set-gtid-purged=OFF --single-transaction --flush-logs --quick --databases db1 --tables t1 t2 | gzip > t1_t2.sql.gz
```

3. 条件导出，导出db1表t1中id=1的数据。

```
mysqldump --host=127.0.0.1 --port=3306 --user=root --password --hex-blob --set-gtid-purged=OFF --single-transaction --flush-logs --quick --databases db1 --tables t1 --where='id=1' > t1_id.sql
```

4. 导出db1下所有表结构，而不导出数据。

```
mysqldump --host=127.0.0.1 --port=3306 --user=root --password --no-data --set-gtid-purged=OFF --single-transaction -n --flush-logs --quick --databases db1 > db1_table.sql
```

5. 除db1下的表和数据外，其他对象全部导出。

```
mysqldump --host=127.0.0.1 --port=3306 --user=root --password --set-gtid-purged=OFF -F -n -t -d -E -R db1 > others.sql
```

## 二、还原数据

1. mysql 命令备份文件还原。（启用gunzip解压缩）

```
gunzip <  db12.sql.gz | mysql --host=127.0.0.1 --port=3306 --user=root --password
```

2. source 命令备份文件还原

```
source /path/to/db1_table.sql
```


## 三、重点选项解析

### `-q(--quick)`

在使用mysqldump导出数据时，倘若添加–q(--quick) 参数时，select出来的结果将不会存放在缓存中，而是直接导出到标准输出中。如果不添加该参数，则会把select的结果放在本地缓存中，然后再输出给客户端。

如果只是备份小量数据，足以放在空闲内存buffer中的话，禁用-q参数，则导出速度会快一些。
对于大数据集，如果没办法完全储存在内存缓存中时，就会产生swap。对于大数据集的导出，不添加-q参数，不但会消耗主机的内存，也可能会造成数据库主机因无可用内存继而宕机的严重后果。
因此，如果使用mysqldump来备份数据时，建议添加-q参数。

导出示例：

> mysqldump --user=root --password --port=3306 --host=127.0.0.1 --set-gtid-purged=OFF --single-transaction --flush-logs -q test t1>t1.sql


### `--single-transaction`

这个选项设置事务的隔离级别为REPEATABLE READ，在导出数据之前向服务器发送一个START TRANSACTION SQL语句。这个选项只对支持事务的表有效，比如innodb表，因为它导出的数据的状态和 START TRANSACTION 执行时数据库的状态是一致，且不会阻塞其他的应用程序。

当使用这个选项，你应该时刻牢记只有导出的innodb表的状态是一致的（只有innodb支持事务），比如，MyISAM 或MEMORY表使用这个选项导出还是有可能状态改变。

当含有--single-transaction 选项的导出进程正在执行，为了确保导出文件的有效性（表内容和二进制日记的坐标），不能在其他的连接中执行以下

命令：`ALTER TABLE`, `CREATE TABLE`, `DROP TABLE`, `RENAME TABLE`, `TRUNCATE TABLE`。一致性地读操作是不和这些语句隔离的，当使用mysqldump命令导出数据时执行这些命令会引起导出的内容不正确或者失败。

`--single-transaction` option 和 `--lock-tables` 选项是互斥的，因为LOCK TABLES会隐式的提交打开状态的事务（pending transactions）.

导出大表时，联合 `--single-transaction` 和 `--quick` 选项。

### `--flush-logs`

在开始导出前刷新服务器的日志文件。注意，如果你一次性导出很多数据库（使用 `-databases=` 或 `--all-databases` 选项），导出每个库时都会触发日志刷新。

例外是当使用了 `--lock-all-tables` 或 `--master-data` 时，日志只会被刷新一次，那个时候所有表都会被锁住。所以如果你希望你的导出和日志刷新发生在同一个确定的时刻，你需要使用 `--lock-all-tables`，或者 `--master-data` 配合 `--flush-logs`。

### `--order-by-primary`

如果存在主键，或者第一个唯一键，对每个表的记录进行排序。在导出MyISAM表到InnoDB表时有效，但会使得导出工作花费很长时间。

### `--set-gtid-purged=OFF`

```
Warning: A partial dump from a server that has GTIDs will by default include the GTIDs of all transactions, even those that changed suppressed parts of the database. If you don't want to restore GTIDs, pass --set-gtid-purged=OFF. To make a complete dump, pass --all-databases --triggers --routines --events.
```

如果一个数据库开启了GTID，使用mysqldump备份的时候或者说是转储的时候，即使不是MySQL全库(所有库)备份，也会备份整个数据库所有的GTID号。

GTID是为了加强数据库的主备一致性、故障恢复和容错能力，mysqldump备份整个数据库用来做从库的话，那么GTID是必须的(一个MySQL主从复制是开启了GTID的场景下)。

但是如果仅仅是备份单个库或者是导入单个库到其它的数据库(也是开启了GTID)，那么GTID号有重复概率(GTID由UUID+顺序事务ID组成)，所以如果想在数据导入的时候不想导入另外一个数据库全部的GTID，那么可以使用`--set-gtid-purged=OFF`来禁止。

警告的最后一句还说了，如果想备份整个mysql数据库而不是一个或者数据数据库的话，请使用`--all-databases --triggers --routines --events`等参数，当备份整个数据库的时候，建议备份GTID全局唯一事务号。

总结，如果仅仅是导出一个数据库中的某一个库，该数据不是用于主从复制，那么GTID号可以不进行备份，因为一旦备份的话是备份全部的GTID，所以备份单个库的时候最好是关闭GTID，也就是使用`--set-gtid-purged=OFF`，那么该数据导入其它DB的时候会产生新的GTID号。

如果备份单个库时不使用`--set-gtid-purged=OFF`，那么就会导出整个数据库的GTID号码，如果该数据导入其它的数据库，会连着GTID号码一起导入，虽然基本不可能会有GTID重复的概率，但是被导入的数据库会出现多余的GTID号，所以一般情况下备份单个库建议关闭。如果备份整个库的时候，用于全备恢复，一般情况下都是要打开的，其实不打开也会生成新的GTID，主要用于主从复制的时候新建从库，避免主从的GTID不一致，因为按这种方式与主库建立主从复制的话，从库的GTID号与主库一致，如果导出数据时不导出GTID，那么从库数据难以与主库同步(其实这种方式建立主从的情况也很少，一般情况下从库的所有数据都是通过主从复制从主库获取的)。

### `--hex-blob`

使用十六进制格式导出二进制字符串字段。如果有二进制数据就必须使用该选项。影响到的字段类型有BINARY、VARBINARY、BLOB。


## 四、参数解释

```
-A, --all-databases 
Dump all the databases. This will be same as --databases with all databases selected. 
导出全部数据库 

-Y, --all-tablespaces 
Dump all the tablespaces. 
导出全部表空间 

-y, --no-tablespaces 
Do not dump any tablespace information. 
不导出任何表空间信息 

--add-drop-database 
Add a 'DROP DATABASE' before each create. 
每个数据库创建之前添加drop数据库语句 

--add-drop-table 
Add a 'drop table' before each create. 
每个数据表创建之前添加drop数据表语句。(默认为打开状态，使用--skip-add-drop-table取消选项) 

--add-locks 
Add locks around insert statements. 
在每个表导出之前增加LOCK TABLES并且之后UNLOCK  TABLE。(默认为打开状态，使用--skip-add-locks取消选项) 

--allow-keywords 
Allow creation of column names that are keywords. 
允许创建是关键词的列名字。 

--character-sets-dir=name 
Directory where character sets are. 
字符集文件的目录 

-i, --comments 
Write additional information. 
附加注释信息。默认为打开，可以用--skip-comments取消 

--compatible=name 
Change the dump to be compatible with a given mode. By default tables are dumped in a format optimized for MySQL. Legal modes are: ansi, mysql323, mysql40, postgresql, oracle, mssql, db2, maxdb, no_key_options, no_table_options, no_field_options. One can use several modes separated by commas. Note: Requires MySQL server version 4.1.0 or higher. This option is ignored with earlier server versions. 
导出的数据将和其它数据库或旧版本的MySQL 相兼容。值可以为ansi、mysql323、mysql40、postgresql、oracle、mssql、db2、maxdb、no_key_options、no_tables_options、no_field_options等。要使用几个值，用逗号将它们隔开。它并不保证能完全兼容，而是尽量兼容。 

--compact 
Give less verbose output (useful for debugging). Disables structure comments and header/footer constructs.  Enables options --skip-add-drop-table --no-set-names --skip-disable-keys --skip-add-locks 
导出更少的输出信息(用于调试)。去掉注释和头尾等结构。可以使用选项：--skip-add-drop-table  --skip-add-locks --skip-comments --skip-disable-keys 

-c, --complete-insert 
Use complete insert statements. 
使用完整的insert语句(包含列名称)。这么做能提高插入效率，但是可能会受到max_allowed_packet参数的影响而导致插入失败。 

-C, --compress 
Use compression in server/client protocol. 
在客户端和服务器之间启用压缩传递所有信息 

--create-options 
Include all MySQL specific create options. 
在CREATE TABLE语句中包括所有MySQL特性选项。(默认为打开状态) 

-B, --databases 
To dump several databases. Note the difference in usage; In this case no tables are given. All name arguments are regarded as databasenames. 'USE db_name;' will be included in the output. 
导出数据库。参数后面所有名字参量都被看作数据库名。 

-#, --debug[=#] 
This is a non-debug version. Catch this and exit 
输出debug信息，用于调试。 

--debug-check 
Check memory and open file usage at exit. 
检查内存和打开文件使用说明并退出。 

--debug-info 
Print some debug info at exit. 
输出调试信息并退出 

--default-character-set=name 
Set the default character set. 
设置默认字符集 

--delayed-insert 
Insert rows with INSERT DELAYED; 
采用延时插入方式（INSERT DELAYED）导出数据 

--delete-master-logs 
Delete logs on master after backup. This automatically enables --master-data. 
master备份后删除日志. 这个参数将自动激活--master-data。 

-K, --disable-keys 
'/*!40000 ALTER TABLE tb_name DISABLE KEYS */; and '/*!40000 ALTER TABLE tb_name ENABLE KEYS */; will be put in the output. 
对于每个表，用/*!40000 ALTER TABLE tbl_name DISABLE KEYS */;和/*!40000 ALTER TABLE tbl_name ENABLE KEYS */;语句引用INSERT语句。这样可以更快地导入dump出来的文件，因为它是在插入所有行后创建索引的。该选项只适合MyISAM表，默认为打开状态。 

-E, --events 
Dump events. 
导出事件。 

-e, --extended-insert 
Allows utilization of the new, much faster INSERT syntax. 
使用具有多个VALUES列的INSERT语法。这样使导出文件更小，并加速导入时的速度。默认为打开状态，使用--skip-extended-insert取消选项。 

--fields-terminated-by=name 
Fields in the textfile are terminated by ... 
导出文件中忽略给定字段。与--tab选项一起使用，不能用于--databases和--all-databases选项 

--fields-enclosed-by=name 
Fields in the importfile are enclosed by ... 
输出文件中的各个字段用给定字符包裹。与--tab选项一起使用，不能用于--databases和--all-databases选项 

--fields-optionally-enclosed-by=name 
Fields in the i.file are opt. enclosed by ... 
输出文件中的各个字段用给定字符选择性包裹。与--tab选项一起使用，不能用于--databases和--all-databases选项 

--fields-escaped-by=name 
Fields in the i.file are escaped by ... 
输出文件中的各个字段忽略给定字符。与--tab选项一起使用，不能用于--databases和--all-databases选项 

-F, --flush-logs 
Flush logs file in server before starting dump. Note that if you dump many databases at once (using the option --databases= or --all-databases), the logs will be flushed for each database dumped. The exception is when using --lock-all-tables or --master-data: in this case the logs will be flushed only once, corresponding to the moment all tables are locked. So if you want your dump and the log flush to happen at the same exact moment you should use --lock-all-tables or --master-data with --flush-logs 
开始导出之前刷新日志。 

--flush-privileges 
Emit a FLUSH PRIVILEGES statement after dumping the mysql database.  This option should be used any time the dump contains the mysql database and any other database that depends on the data in the mysql database for proper restore. 
在导出mysql数据库之后，发出一条FLUSH  PRIVILEGES 语句。为了正确恢复，该选项应该用于导出mysql数据库和依赖mysql数据库数据的任何时候。 

-f, --force 
Continue even if we get an sql-error. 
在导出过程中忽略出现的SQL错误。 

-?, --help 
Display this help message and exit. 
显示帮助信息并退出。 

--hex-blob 
Dump binary strings (BINARY, VARBINARY, BLOB) in hexadecimal format. 
使用十六进制格式导出二进制字符串字段。如果有二进制数据就必须使用该选项。影响到的字段类型有BINARY、VARBINARY、BLOB。 

-h, --host=name 
Connect to host. 
需要导出的主机信息 

--ignore-table=name 
Do not dump the specified table. To specify more than one table to ignore, use the directive multiple times, once for each table.  Each table must be specified with both database and table names, e.g. --ignore-table=database.table 
不导出指定表。指定忽略多个表时，需要重复多次，每次一个表。每个表必须同时指定数据库和表名。例如：--ignore-table=database.table1 --ignore-table=database.table2 …… 

--insert-ignore 
Insert rows with INSERT IGNORE. 
在插入行时使用INSERT IGNORE语句. 

--lines-terminated-by=name 
Lines in the i.file are terminated by ... 
输出文件的每行用给定字符串划分。与--tab选项一起使用，不能用于--databases和--all-databases选项。 

-x, --lock-all-tables 
Locks all tables across all databases. This is achieved by taking a global read lock for the duration of the whole dump. Automatically turns --single-transaction and --lock-tables off. 
提交请求锁定所有数据库中的所有表，以保证数据的一致性。这是一个全局读锁，并且自动关闭--single-transaction 和--lock-tables 选项。 

-l, --lock-tables 
Lock all tables for read. 
开始导出前，锁定所有表。用READ  LOCAL锁定表以允许MyISAM表并行插入。对于支持事务的表例如InnoDB和BDB，--single-transaction是一个更好的选择，因为它根本不需要锁定表。请注意当导出多个数据库时，--lock-tables分别为每个数据库锁定表。因此，该选项不能保证导出文件中的表在数据库之间的逻辑一致性。不同数据库表的导出状态可以完全不同。 

--log-error=name 
Append warnings and errors to given file. 
附加警告和错误信息到给定文件 

--no-autocommit 
Wrap tables with autocommit/commit statements. 
使用autocommit/commit 语句包裹表 

-n, --no-create-db 
'CREATE DATABASE /*!32312 IF NOT EXISTS*/ db_name;' will not be put in the output. The above line will be added otherwise, if --databases or --all-databases option was given.}. 
只导出数据，而不添加CREATE DATABASE 语句 

-t, --no-create-info 
Don't write table creation info. 
只导出数据，而不添加CREATE TABLE 语句 

-d, --no-data 
No row information. 
不导出任何数据，只导出数据库表结构 

--opt 
Same as --add-drop-table, --add-locks, --create-options, --quick, --extended-insert, --lock-tables, --set-charset, and --disable-keys. Enabled by default, disable with --skip-opt. 
等同于--add-drop-table,  --add-locks, --create-options, --quick, --extended-insert, --lock-tables,  --set-charset, --disable-keys 该选项默认开启,  可以用--skip-opt禁用. 

--order-by-primary 
Sorts each table's rows by primary key, or first unique key, if such a key exists.  Useful when dumping a MyISAM table to be loaded into an InnoDB table, but will make the dump itself take considerably longer. 
如果存在主键，或者第一个唯一键，对每个表的记录进行排序。在导出MyISAM表到InnoDB表时有效，但会使得导出工作花费很长时间。 

-p, --password[=name] 
Password to use when connecting to server. If password is not given it's solicited on the tty. 
连接数据库密码 

-W, --pipe 
Use named pipes to connect to server. 
使用命名管道连接mysql(windows系统可用) 

-P, --port=# 
Port number to use for connection. 
连接数据库端口号 

--protocol=name 
The protocol of connection (tcp,socket,pipe,memory). 
使用的连接协议，包括：tcp, socket, pipe, memory. 

-q, --quick 
Don't buffer query, dump directly to stdout. 
不缓冲查询，直接导出到标准输出。默认为打开状态，使用--skip-quick取消该选项。 

-Q, --quote-names 
Quote table and column names with backticks (`). 
使用（`）引起表和列名。默认为打开状态，使用--skip-quote-names取消该选项。 

--replace 
Use REPLACE INTO instead of INSERT INTO. 
使用REPLACE INTO 取代INSERT INTO. 

-r, --result-file=name 
Direct output to a given file. This option should be used in MSDOS, because it prevents new line '\n' from being converted to '\r\n' (carriage return + line feed). 
直接输出到指定文件中。该选项应该用在使用回车换行对（\\r\\n）换行的系统上（例如：DOS，Windows）。该选项确保只有一行被使用。 

-R, --routines 
Dump stored routines (functions and procedures). 
导出存储过程以及自定义函数。 

--set-charset 
Add 'SET NAMES default_character_set' to the output. Enabled by default; suppress with --skip-set-charset. 
添加'SET NAMES  default_character_set'到输出文件。默认为打开状态，使用--skip-set-charset关闭选项。 

-O, --set-variable=name 
Change the value of a variable. Please note that this option is deprecated; you can set variables directly with --variable-name=value. 
设置变量的值 

--dump-date 
Put a dump date to the end of the output. 
添加DUMP时间到输出末尾 

--skip-opt 
Disable --opt. Disables --add-drop-table, --add-locks, --create-options, --quick, --extended-insert, --lock-tables, --set-charset, and --disable-keys. 
禁用–opt选项. 

-S, --socket=name 
Socket file to use for connection. 
指定连接mysql的socket文件位置，默认路径/tmp/mysql.sock 

-T, --tab=name 
Creates tab separated textfile for each table to given path. (creates .sql and .txt files). NOTE: This only works if mysqldump is run on the same machine as the mysqld daemon. 
为每个表在给定路径创建tab分割的文本文件。注意：仅仅用于mysqldump和mysqld服务器运行在相同机器上。 

--tables 
Overrides option --databases (-B). 
覆盖--databases (-B)参数，指定需要导出的表名。 

--triggers 
Dump triggers for each dumped table 
导出触发器。该选项默认启用，用--skip-triggers禁用它。 

--tz-utc 
SET TIME_ZONE='+00:00' at top of dump to allow dumping of TIMESTAMP data when a server has data in different time zones or data is being moved between servers with different time zones. 
在导出顶部设置时区TIME_ZONE='+00:00' ，以保证在不同时区导出的TIMESTAMP 数据或者数据被移动其他时区时的正确性。 

-u, --user=name 
User for login if not current user. 
指定连接的用户名。 

-v, --verbose 
Print info about the various stages. 
输出多种平台信息。 

-V, --version 
Output version information and exit. 
输出mysqldump版本信息并退出 

-w, --where=name 
Dump only selected records; QUOTES mandatory! 
只转储给定的WHERE条件选择的记录。请注意如果条件包含命令解释符专用空格或字符，一定要将条件引用起来。 

-X, --xml                               
Dump a database as well formed XML. 
导出XML格式.
   
```


## 5、相关链接

- [使用mysqldump导出大表的注意事项](https://support.huaweicloud.com/trouble-rds/rds_12_0015.html)
- [mysqldump的6大使用场景的导出命令](https://support.huaweicloud.com/trouble-rds/rds_12_0018.html)
- [Mysqldump 的–Single-Transaction选项](https://www.javacoder.cn/?p=49)
- [使用转储和还原将 MariaDB 数据库迁移到 Azure Database for MariaDB](https://learn.microsoft.com/zh-cn/azure/mariadb/howto-migrate-dump-restore)
- [MySQL备份命令mysqldump参数说明与示例](https://segmentfault.com/a/1190000002428533)
- [mysqldump 命令参数详解](https://cloud.tencent.com/developer/article/1994050)
- [mysqldump --set-gtid-purged=OFF 参数解析](https://www.cnblogs.com/ybyqjzl/p/12428039.html)

