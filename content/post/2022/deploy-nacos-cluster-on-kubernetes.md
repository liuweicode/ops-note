+++
title = "在 Kubernetes 上部署 Nacos 集群"
author = "liuwei"
date = "2022-09-15"
tags = [
    "kubernetes",
    "nacos",
]
categories = [
    "k8s",
]
+++

![nacos-screenshot](https://static.liuwei.co/202209/nacos/nacos-screenshot.png)

## 1. 下载源码 2.1.1 版本

```shell
wget https://github.com/alibaba/nacos/archive/refs/tags/2.1.1.zip
```

## 2. 创建数据库

```sql
CREATE DATABASE IF NOT EXISTS nacos-dev DEFAULT CHARSET utf8 COLLATE utf8_general_ci;
```

## 3. 初始化数据库

```sql
source nacos-2.1.1/distribution/conf/nacos-mysql.sql
```

## 4. 部署

### 4.1 修改nacos.yaml

![修改数据库配置](https://static.liuwei.co/202209/nacos/db-config.png) 


### 4.2 修改 replicas

- 这里设置为`3`，需要与下面的`NACOS_SERVERS`对应的上;

- `NACOS_SERVERS` 配置的格式为`$(podname).$(headless-server-name).svc.cluster.local`;

- StatefulSets Pod YAML中ServiceName必须和其暴露SVC的名字一致，否则无法访问Pod域名;

![config](https://static.liuwei.co/202209/nacos/config.png)

![nacos-servers](https://static.liuwei.co/202209/nacos/nacos-servers.png)

### 4.2 部署statefulset

```shell
kubectl apply -f nacos.yaml
```

![k9s-nacos](https://static.liuwei.co/202209/nacos/k9s-nacos.png)


## 5. 相关链接

- 项目代码: https://github.com/liuweicode/deploy-nacos-cluster-on-kubernetes


