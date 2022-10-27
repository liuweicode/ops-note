+++
title = "EnvoyFilter 在访问日志中打印 HTTP body"
slug = "print-req-resp-body-in-envoyfilter"
author = "liuwei"
date = "2022-04-11"
categories = [
    "envoy",
]
tags = [
    "envoyfilter",
    "lua",
]
+++

## 1. 问题背景

最近有一个全局打印请求参数和响应内容的需求，于是添加了一个Envoy过滤器，在调试`EnvoyFilter`的时候，打印出来的 response body 始终是空，并且报错如下：

```
 [libprotobuf ERROR external/com_google_protobuf/src/google/protobuf/wire_format_lite.cc:577] String field 'google.protobuf.Value.string_value' contains invalid UTF-8 data when serializing a protocol buffer. Use the 'bytes' type if you intend to send raw bytes.
```

![error](https://static.liuwei.co/202210/1665986719.png)

## 2. 问题原因

经排查后端业务系统的` openresty` 启用了 `gzip` 压缩，所以当返回到达 `istio` 网关的时候，无法解析 `response` 的响应体；

![nginx-gzip](https://static.liuwei.co/202210/1665987445.png)

## 3. Envoy 过滤器

### 3.1. 添加过滤器代码

```yaml
apiVersion: networking.istio.io/v1alpha3
kind: EnvoyFilter
metadata:
  name: log-req-resp-body
  namespace: default
spec:
  workloadSelector:
    labels:
      app: test
  configPatches:
    - applyTo: HTTP_FILTER
      match:
        context: SIDECAR_INBOUND
        listener:
          filterChain:
            filter:
              name: envoy.filters.network.http_connection_manager
              subFilter:
                name: envoy.filters.http.router
          portNumber: 80
        proxy:
          proxyVersion: ^1\.13.*
      patch:
        operation: INSERT_BEFORE
        value:
          name: envoy.lua
          typed_config:
            '@type': type.googleapis.com/envoy.extensions.filters.http.lua.v3.Lua
            inlineCode: |
              function envoy_on_request(request_handle)
                local headers = request_handle:headers()
                local headersMap = {}
                for key, value in pairs(headers) do
                  headersMap[key] = value
                end                
                request_handle:streamInfo():dynamicMetadata():set("envoy.lua","request_headers",headersMap)                    
                local requestBody = ""
                for chunk in request_handle:bodyChunks() do
                  if (chunk:length() > 0) then
                    requestBody = requestBody .. chunk:getBytes(0, chunk:length())
                  end
                end
                request_handle:streamInfo():dynamicMetadata():set("envoy.lua","request_body",requestBody)                    
              end

              function envoy_on_response(response_handle)
                local headers = response_handle:headers()
                local headersMap = {}
                for key, value in pairs(headers) do
                  headersMap[key] = value
                end                
                response_handle:streamInfo():dynamicMetadata():set("envoy.lua","response_headers",headersMap)                    
                local responseBody = ""
                for chunk in response_handle:bodyChunks() do
                  if (chunk:length() > 0) then
                    responseBody = responseBody .. chunk:getBytes(0, chunk:length())
                  end
                end
                response_handle:streamInfo():dynamicMetadata():set("envoy.lua","response_body",responseBody)                    
              end
```

### 3.2. 自定义访问日志格式

在下图位置添加自定义日志格式：

```
request_body %DYNAMIC_METADATA(envoy.lua:request_body)%
response_body %DYNAMIC_METADATA(envoy.lua:response_body)%
request_headers %DYNAMIC_METADATA(envoy.lua:request_headers)%
response_headers %DYNAMIC_METADATA(envoy.lua:response_headers)%
```

![自定义日志格式](https://static.liuwei.co/202210/1665996430.png)


### 3.3. 效果

![效果](https://static.liuwei.co/202210/1665996823.png)




