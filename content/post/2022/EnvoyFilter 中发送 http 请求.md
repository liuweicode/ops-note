+++
title = "EnvoyFilter 中发送 http 请求"
slug = "make-httpcall-in-envoyfilter"
author = "liuwei"
date = "2022-05-17"
categories = [
    "envoy",
]
tags = [
    "envoyfilter",
    "lua",
]
+++

目前有一个需求是在网关中对请求的参数进行解密，将解密后的原始数据放在请求头中，再转发给后端业务服务。

这样做的好处在于：

1. 方便业务服务直接获取解密后的数据；
2. 网关可以根据用户信息进行限流，全局定制化更高；

于是研究在 EnvoyFilter 中向内部加解密服务发送解密请求如下：

```yaml
apiVersion: networking.istio.io/v1alpha3
kind: EnvoyFilter
metadata:
  name: encryption-test
  namespace: default
spec:
  configPatches:
  - applyTo: HTTP_FILTER
    match:
      context: SIDECAR_INBOUND
      listener:
        portNumber: 80
        filterChain:
          filter:
            name: "envoy.http_connection_manager"
            subFilter:
              name: "envoy.router"
    patch:
      operation: INSERT_BEFORE
      value:
       name: envoy.lua
       typed_config:
         '@type': type.googleapis.com/envoy.extensions.filters.http.lua.v3.Lua
         inlineCode: |
           function envoy_on_request(request_handle)
              local request_body_buffer = request_handle:body()
              local request_body_data = request_body_buffer:getBytes(0, request_body_buffer:length())
              request_handle:logInfo("request_body_data="..request_body_data)

              local headers, body = request_handle:httpCall(
              "outbound|8080||my-svc.my-namespace.svc.cluster.local",
              {
               ["Secret"] = "1234567890",
               ["Content-Type"] = "application/json",
               [":method"] = "POST",
               [":path"] = "/v1/decrypt",
               [":authority"] = "my-svc.my-namespace.svc.cluster.local"
              },
             "{\"cipherType\":\"SM4\",\"encryptStr\":\"加密串\"}",
             5000)

             request_handle:logInfo("status="..headers[":status"])
             request_handle:logInfo("body="..body)
             request_handle:headers():add("info", body)
           end
```

