#!/bin/bash

set -eux

BUILD_NAME='ops-note'
BUILD_VERSION='liuwei.co'

hugo -D

docker build --no-cache -t $BUILD_NAME:$BUILD_VERSION -f Dockerfile .

docker images | grep $BUILD_VERSION

IMAGETAG=$(docker images | grep $BUILD_VERSION | head -n 1 | awk '{print $3}')

echo $IMAGETAG

docker tag $IMAGETAG toplist-registry.cn-shanghai.cr.aliyuncs.com/88/$BUILD_NAME:$BUILD_VERSION

docker push toplist-registry.cn-shanghai.cr.aliyuncs.com/88/$BUILD_NAME:$BUILD_VERSION

kubectl rollout restart deploy ops-note -n pwk

sleep 2

kubectl get pods -n pwk -w
