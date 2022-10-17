+++
title = "Istio 网关统一响应格式"
author = "liuwei"
date = "2022-05-18"
categories = [
    "envoy",
]
tags = [
    "envoyfilter",
    "lua",
]
+++

## 1. 问题背景

目前我们的接口返回的统一格式为：

1. http response status 响应码永远是 `200`

2. http response body 响应体格式为：`{"code":响应码,"message":"消息"}`

但当启用了限流模块后，响应码会改为 429 并且无响应体；

前端工程师要求，当启用限流模块后需要返回响应码为200，响应体统一格式为：`{"code":429,"message":"Too Many Requests"}`；

## 2. 问题解决

在网关层添加了EnvoyFilter如下：

```yaml
apiVersion: networking.istio.io/v1alpha3
kind: EnvoyFilter
spec:
  configPatches:
  - applyTo: HTTP_FILTER
    match:
      context: GATEWAY
      listener:
        filterChain:
          filter:
            name: "envoy.filters.network.http_connection_manager"
            subFilter:
              name: "envoy.filters.http.router"
    patch:
      operation: INSERT_BEFORE
      value: # lua filter specification
        name: envoy.lua
        typed_config:
          "@type": "type.googleapis.com/envoy.extensions.filters.http.lua.v3.Lua"
          inlineCode: |-
            function envoy_on_response(response_handle)
                if response_handle:headers():get(":status") == "429" then
                    response_handle:logInfo("into...429")
                    response_handle:headers():replace(":status", "200")
                    response_handle:headers():replace("content-type", "application/json;charset=UTF-8")
                    response_handle:headers():replace("content-length", 42)
                    local responseBody = '{"code":429,"message":"Too Many Requests"}';
                    local last
                    for chunk in response_handle:bodyChunks() do
                     chunk:setBytes("")
                     last = chunk
                    end
                    local content_length = last:setBytes(responseBody)
                    response_handle:logInfo("new content_length="..content_length)
                end
            end
```

