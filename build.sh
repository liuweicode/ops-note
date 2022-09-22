#!/bin/bash

set -eux

hugo -D

docker build -t ops-note:v1 -f Dockerfile .

docker images | grep 'ops-note'

IMAGETAG=$(docker images | grep 'ops-note' | head -n 1 | awk '{print $3}')

echo $IMAGETAG

docker tag $IMAGETAG toplist-registry.cn-shanghai.cr.aliyuncs.com/88/ops-note:v1

docker push toplist-registry.cn-shanghai.cr.aliyuncs.com/88/ops-note:v1

kubectl rollout restart deploy ops-note -n pwk

sleep 2

kubectl get pods -n pwk -w
