+++
title = "在 Kubernetes 上部署 Archery DMS"
slug = "deploy-archery-dms-on-kubernetes"
author = "liuwei"
date = "2022-10-13"
tags = [
    "kubernetes",
    "archery",
	"SQL审核平台"
]
categories = [
    "k8s",
]
+++

![archery dms dashboard](https://static.liuwei.co/202210/1665638990.png)

Archery 是一个 SQL 审核查询平台；

功能模块包括：

- 权限管理
- 工作流
- 实例管理
- SQL审核
- SQL查询
- SQL优化
- 消息通知
- 工具插件
- 云数据库

部署方式也比较简单，按照官方的 [docker部署文档](https://www.archerydms.com/installation/docker/) ，稍微修改一下，部署到k8s上即可；

## 1. 将官方镜像备份至私有仓库

```shell
docker pull hanchuanchuan/goinception:v1.3.0
docker tag xx toplist-registry.cn-shanghai.cr.aliyuncs.com/88/tl-archery-dms:goinception-v1.3.0
docker push toplist-registry.cn-shanghai.cr.aliyuncs.com/88/tl-archery-dms:goinception-v1.3.0
```


```shell
docker pull docker pull hhyo/archery:v1.9.1
docker tag xx toplist-registry.cn-shanghai.cr.aliyuncs.com/88/tl-archery-dms:archery-v1.9.1
docker push toplist-registry.cn-shanghai.cr.aliyuncs.com/88/tl-archery-dms:archery-v1.9.1
```

## 2. 创建configmap

```shell
kubectl create configmap uat-archery --from-file=configmap/archery/docs.md --from-file=configmap/archery/settings.py --from-file=configmap/archery/soar.yaml -n uat-archery
kubectl create configmap uat-archery-goinception --from-file=configmap/goinception/config.toml -n uat-archery
```
![create configmap](https://static.liuwei.co/202210/1665642517.png)

## 3. 创建pv&pvc

这里使用的是阿里云的nas绑定pv和pvc，先在nas上创建好对应的目录：

![目录结构](https://static.liuwei.co/202210/1665643171.png)

创建pv&pvc

```shell
kubectl apply -f pv
kubectl apply -f pvc
```
![创建pv&pvc](https://static.liuwei.co/202210/1665643411.png)

## 4. 部署

### 4.1 创建deployment

```shell
kubectl apply -f deployment
```

### 4.2 按照官网说明初始化数据库

https://archerydms.com/installation/docker/

```
# 表结构初始化
docker exec -ti archery /bin/bash
cd /opt/archery
source /opt/venv4archery/bin/activate
python3 manage.py makemigrations sql
python3 manage.py migrate

# 数据初始化
python3 manage.py dbshell<sql/fixtures/auth_group.sql
python3 manage.py dbshell<src/init_sql/mysql_slow_query_review.sql

# 创建管理用户
python3 manage.py createsuperuser

# 重启
docker restart archery

# 日志查看和问题排查
docker logs archery -f --tail=50
```

## 5. 相关链接

- 官网地址: https://archerydms.com
- 项目代码: https://github.com/liuweicode/deploy-archery-dms-on-kubernetes


