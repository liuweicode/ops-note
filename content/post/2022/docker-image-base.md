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

修改时区为中国上海；
修改为中科大的源；

1.2 openjdk-8-jre-slim-bullseye

修改时区为中国上海；
修改为中科大的源；

## 2. alpine

官方镜像地址: https://hub.docker.com/_/alpine

2.1. alpine-3.16-base

修改时区为中国上海；
修改为中科大的源；

## 相关链接

项目代码: https://github.com/liuweicode/docker-image-base
