#!/bin/bash

set -eux

COMMIT_MESSAGE=$1

BUILD_NAME='ops-note'
BUILD_VERSION='liuwei.co'

rm -rf public/*

hugo -D

docker build --no-cache -t $BUILD_NAME:$BUILD_VERSION -f Dockerfile .

docker images | grep $BUILD_VERSION

IMAGETAG=$(docker images | grep $BUILD_VERSION | head -n 1 | awk '{print $3}')

echo $IMAGETAG

docker tag $IMAGETAG toplist-registry.cn-shanghai.cr.aliyuncs.com/88/$BUILD_NAME:$BUILD_VERSION

docker push toplist-registry.cn-shanghai.cr.aliyuncs.com/88/$BUILD_NAME:$BUILD_VERSION

kubectl rollout restart deploy ops-note -n pwk

git add --all

git commit -m $COMMIT_MESSAGE

git push origin main

sleep 2

kubectl get pods -n pwk -w
