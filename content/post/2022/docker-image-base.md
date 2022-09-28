+++
title = "构建 docker 基础镜像"
author = "liuwei"
date = "2022-09-20"
tags = [
    "kubernetes",
    "docker",
]
categories = [
    "云原生",
]
+++

基础镜像主要是修改源及时区，方便后续基于此镜像构建其他应用镜像；

镜像源推荐中科大的源: https://mirrors.ustc.edu.cn

## 1. openjdk
官方镜像地址: https://hub.docker.com/_/openjdk

1.1. openjdk-8-jre-slim-buster

- 修改时区为中国上海；
- 修改为中科大的源；

1.2 openjdk-8-jre-slim-bullseye

- 修改时区为中国上海；
- 修改为中科大的源；

## 2. alpine

官方镜像地址: https://hub.docker.com/_/alpine

2.1. alpine-3.16-base

- 修改时区为中国上海；
- 修改为中科大的源；

2.2 alpine-3.16-glibc-2.35-r0

- 修改时区为中国上海；
- 修改为中科大的源；
- 安装 glibc

## 3. openresty

3.1 openresty-1.19.9.1rc1-alpine-3.16-glibc-2.35-r0

- 镜像基于 suxz/alpine:alpine-3.16-glibc-2.35-r0-cn-base 构建；
- 编译构建openresty-1.19.9.1rc1

## 4. php

官方镜像地址: https://hub.docker.com/_/php

安装扩展：

- 可参考官方文档安装其他扩展；![How to install more PHP extensions](https://hub.docker.com/_/php)
- ![Easy installation of PHP extensions in official PHP Docker images](https://github.com/mlocati/docker-php-extension-installer)


4.1 7.3.33-fpm-alpine3.14-base

- 修改时区为中国上海；
- 修改为中科大的源；

4.2 7.3.33-fpm-base

- 修改时区为中国上海；
- 修改为中科大的源；


## 相关链接

项目代码: https://github.com/liuweicode/docker-image-base
