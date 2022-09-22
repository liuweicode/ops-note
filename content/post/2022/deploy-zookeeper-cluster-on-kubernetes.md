+++
title = "在 Kubernetes 上部署 ZooKeeper 集群"
author = "liuwei"
date = "2022-09-19"
tags = [
    "kubernetes",
    "zookeeper",
]
categories = [
    "k8s",
    "syntax",
]
+++

Apache ZooKeeper 是一个分布式的开源协调服务，用于分布式系统。 ZooKeeper 允许你读取、写入数据和发现数据更新。 数据按层次结构组织在文件系统中，并复制到 ensemble（一个 ZooKeeper 服务器的集合） 中所有的 ZooKeeper 服务器。对数据的所有操作都是原子的和顺序一致的。 ZooKeeper 通过 Zab 一致性协议在 ensemble 的所有服务器之间复制一个状态机来确保这个特性。

Ensemble 使用 Zab 协议选举一个领导者，在选举出领导者前不能写入数据。 一旦选举出了领导者，ensemble 使用 Zab 保证所有写入被复制到一个 quorum， 然后这些写入操作才会被确认并对客户端可用。 如果没有遵照加权 quorums，一个 quorum 表示包含当前领导者的 ensemble 的多数成员。 例如，如果 ensemble 有 3 个服务器，一个包含领导者的成员和另一个服务器就组成了一个 quorum。 如果 ensemble 不能达成一个 quorum，数据将不能被写入。

ZooKeeper 在内存中保存它们的整个状态机，但是每个改变都被写入一个在存储介质上的持久 WAL（Write Ahead Log）。 当一个服务器出现故障时，它能够通过回放 WAL 恢复之前的状态。 为了防止 WAL 无限制的增长，ZooKeeper 服务器会定期的将内存状态快照保存到存储介质。 这些快照能够直接加载到内存中，所有在这个快照之前的 WAL 条目都可以被安全的丢弃。


## 1. 环境

- Zookeeper 3.7.1

- 阿里云容器服务 ACK

```
kubectl version
Client Version: version.Info{Major:"1", Minor:"21", GitVersion:"v1.21.1", GitCommit:"5e58841cce77d4bc13713ad2b91fa0d961e69192", GitTreeState:"clean", BuildDate:"2021-05-12T14:18:45Z", GoVersion:"go1.16.4", Compiler:"gc", Platform:"darwin/amd64"}
Server Version: version.Info{Major:"1", Minor:"22+", GitVersion:"v1.22.10-aliyun.1", GitCommit:"890f58821240c8db6e3076942fd574e8820451c5", GitTreeState:"clean", BuildDate:"2022-06-16T07:46:40Z", GoVersion:"go1.16.15", Compiler:"gc", Platform:"linux/amd64"}
```

## 2. 构建镜像

将官方镜像打包至私有仓库

```shell
./build.sh
```
![build-docker-image](https://static.liuwei.co/202209/zk/build-docker-image.png)

## 3. 存储

- **dataDir**：zk用于保存内存数据库的快照的目录，除非设置了dataLogDir，否则这个目录也用来保存更新数据库的事务日志。在生产环境使用的zk集群，强烈建议设置dataLogDir，让dataDir只存放快照，因为写快照的开销很低，这样dataDir就可以和其他日志目录的挂载点放在一起。

- **dataLogDir**: zk的事务日志路径

### 根据官方建议，将`dataDir`和`dataLogDir`分开存储

- [https://hub.docker.com/_/zookeeper](https://hub.docker.com/_/zookeeper)

![data](https://static.liuwei.co/202209/zk/data.png)


- 创建 StorageClass

我这里使用阿里云云盘做存储

```shell
kubectl apply -f zk-storageclass.yaml
```

## 4. 创建ConfigMap

```shell
kubectl create configmap uat-zookeeper-config --from-file=zoo.cfg  -n uat-zookeeper
```

## 5. 创建 ZooKeeper StatefulSet

```shell
kubectl apply -f zk.yaml
```

## 6. 注意事项

采用postStart在pod启动的时候，创建myid

![myid](https://static.liuwei.co/202209/zk/myid.png)

## 7. 相关链接

- 项目代码: https://github.com/liuweicode/deploy-zookeeper-cluster-on-kubernetes

