+++
title = "docker 中打开php-fpm慢日志报错"
slug = "failed to ptrace(ATTACH) child 10: Operation not permitted"
author = "liuwei"
date = "2022-11-08"
tags = [
    "php-fpm",
    "docker",
]
categories = [
    "php",
]
+++

## 1. 问题

在部署php-fpm的时候打开了慢日志如下：

```
; PHP文件执行过慢的日志，会准确的记录具体哪一行代码太慢，这个非常有用，在设置了时间时生效。
slowlog = /var/log/php-fpm/fpm-php.$pool.slow.log

; 超过这个运行时间就会写慢日志
request_slowlog_timeout = 2s
```

运行时报错如下：

ERROR: failed to ptrace(ATTACH) child 10: Operation not permitted (1)

![error](https://static.liuwei.co/202211/1667885030.png)

## 2. 解决方案

```
securityContext:
  capabilities:
	add:
	- SYS_PTRACE
```

![sloved](https://static.liuwei.co/202211/1667887694.png)

![sloved2](https://static.liuwei.co/202211/1667887729.png)

![sloved3](https://static.liuwei.co/202211/1667887760.png)


## 3. 相关链接

- https://unofficial-kubernetes.readthedocs.io/en/latest/concepts/policy/container-capabilities/
