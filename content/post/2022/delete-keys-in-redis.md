+++
title = "redis 删除大量 key"
author = "liuwei"
date = "2022-08-15"
categories = [
    "redis",
]
+++

**禁止使用 FLUSHDB !!!**

**禁止使用 FLUSHDB !!!**

**禁止使用 FLUSHDB !!!**

重要的事情说3遍，我们有同事在生产环境直接FLUSHDB，直接导致redis挂了。

## 1. 删除命令

```shell
redis-cli -h localhost -p 6379 -a 'password' --scan --pattern '*' -n 1 >> db1-keys.txt

time cat db1-keys.txt | xargs -n 10000 redis-cli  -h localhost -p 6379 -a 'password' -n 1 DEL | tee count.txt

```

## 2. 删除脚本

```shell
#!/bin/sh

EXEC_TIME=`date '+%Y%m%d%H%M%y'`

REDIS_HOST=$1
REDIS_PASSWORD=$2
REDIS_DB=$3
PATTEN=$4
NUMBERS=$5

TMP_FILE_NAME=redis-db-$REDIS_DB-$EXEC_TIME.txt
RESULT_FILE_NAME=redis-db-$REDIS_DB-$EXEC_TIME-result.txt

echo "数据库地址: $REDIS_HOST"
echo "数据库密码: $REDIS_PASSWORD"
echo "数据库DB: $REDIS_DB"
echo "匹配字符串: $PATTEN"
echo "批量删除行数: $NUMBERS"

echo "执行时间: $EXEC_TIME"
echo "Keys文件名: $TMP_FILE_NAME"
echo "执行结果: $RESULT_FILE_NAME"

redis-cli -h $REDIS_HOST -p 6379 -a "$REDIS_PASSWORD" --scan --pattern "$PATTEN" -n $REDIS_DB >> $TMP_FILE_NAME

time cat $TMP_FILE_NAME | xargs -n $NUMBERS redis-cli -h $REDIS_HOST -p 6379 -a "$REDIS_PASSWORD" -n $REDIS_DB DEL | tee $RESULT_FILE_NAME

echo 'Done'
```

将以上脚本保存为`del-redis.sh`使用方法：

```shell
chmod +x del-redis.sh
./del-redis.sh 'localhost' 'password' 1 '*' 1000
```

## 3. 相关链接

- 参考: https://elliotchance.medium.com/deleting-a-huge-number-of-keys-in-redis-3873c1479202



