+++
title = "nginx 代理转发至 IstioGateway 报错 426 Upgrade Required"
author = "liuwei"
date = "2022-05-26"
tags = [
    "nginx",
    "envoy",
]
categories = [
    "ASM",
    "istio",
    "服务网格",
]
+++

## 1. 问题产生背景

由于需要沿用之前的域名，但是之前的域名是解析到ECS绑定的弹性IP上的，所以只好在ECS的nginx上做一层转发:

```nginx
location ^~ /abc/v4/ {
   proxy_pass             http://internal.domain/v4/;
   proxy_redirect          off;
   proxy_set_header        X-Real-IP       $remote_addr;
   proxy_set_header        X-Forwarded-For $proxy_add_x_forwarded_for;
   proxy_set_header        X-TP-Proxy-Domain $host;
   proxy_set_header Connection "";
}
```

但是访问发现报错：427 Upgrade Required;

原因是 **Envoy 默认要求使用 HTTP/1.1 或 HTTP/2，当客户端使用 HTTP/1.0 时就会返回 426 Upgrade Required**

## 2. 解决办法

### 2.1 方法1

nginx 指定 1.1 的 http 版本请求：

```nginx
location ^~ /abc/v4/ {
   proxy_pass             http://internal.domain/v4/;
   proxy_redirect          off;
   proxy_set_header        X-Real-IP       $remote_addr;
   proxy_set_header        X-Forwarded-For $proxy_add_x_forwarded_for;
   proxy_set_header        X-TP-Proxy-Domain $host;
   proxy_set_header Connection "";
   proxy_http_version 1.1;
}
```

### 2.2 方法2

在 `服务网格ASM` - `功能设置` 中，将 `是否启用支持 HTTP 1.0` 打开即可；

![启用支持 HTTP 1.0 - 1](https://static.liuwei.co/202210/1665741682.png)

![启用支持 HTTP 1.0 - 2](https://static.liuwei.co/202210/1665741763.png)



