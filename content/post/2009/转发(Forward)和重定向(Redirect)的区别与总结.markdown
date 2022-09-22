---
layout: post
title:  转发(Forward)和重定向(Redirect)的区别与总结
date:   2009-10-04
categories: [Java]
no-post-nav: true
---

```

request.getRequestDispatcher("路径").forward(request,response);

```

1. 该路径可以是相对于上下文根路径，还可以是相对于当前servlet 的路径。
如：/demo 和 demo 都是合法的路径。
① 如果路径以斜杠（/）开头，则被解释为相对于当前上下文根的路径。
② 如果没有以斜杠（/）开头，则被解释为相对于当前servlet 的路径。
2. 如果用根路径，那么该根路径所指的是该应用程序的根路径 。

Web.xml 文件配置如下：

```

.........
<servlet>
<servlet-name>TestForward</servlet-name>
<servlet-class>com.accp.servlet.TestForward</servlet-class>
</servlet>
<servlet-mapping>
<servlet-name>TestForward</servlet-name>
<url-pattern>/TestForward</url-pattern>
</servlet-mapping>
.........

```

那么请求转发的语句为：
request.getRequestDispatcher("/a/a.jsp").forward(request, response);
斜杠表示相对于该应用程序的根路径。
或者语句为：
request.getRequestDispatcher("a/a.jsp").forward(request, response);
没有斜杠，表示相对于改servlet 的路径。

但此时要注意，因为上面配置改 servlet 时，用的路径是<url-pattern>/TestForward</url-
pattern>，因此上面才可以访问，如果改成<url-pattern>/a/b/TestForward</url-pattern>，此时
用如下方法
request.getRequestDispatcher("a/a.jsp").forward(request, response);
运行，会出404.

因为没有斜杠，用的是相对于改servlet 路径，所以会出现404 错误，正确代码如下：
request.getRequestDispatcher("../../a/a.jsp").forward(request, response);
或者干脆直接用相对于改程序的根路径：
request.getRequestDispatcher("/a/a.jsp").forward(request, response);
因此获得如下经验：
用 request.getRequestDispatcher("路径").forward(request, response);进行请求转发
时，路径最好加上斜杠"/"，表示相对于当前上下文的根路径，也就是程序的根路径。

```

getServletContext().getRequestDispatcher("路径").forward(request,response);

```

1. 该路径必须以斜杠"/"开始，解释为相对于当前上下文根（context root）的路径。
2. ServletContext.getContext()方法可以获得另一个 web 应用程序的上下文对象，利用该上下文对
象调用getRequestDispatcher("路径")方法得到的RequestDispatcher 对象，可以将请求转向到另一个
web 应用程序中的资源，但是要注意的是：要夸web 应用程序访问资源，需要在当前web 应用程序的<context>
元素的设置中，指定crossContext 属性的值为true。
例如：
如果不以斜杠开头，用下列语句转发会报如下错误：
thisthisthisthis.getServletContext().getRequestDispatcher("../../a/a.jsp")
.forward(request, response);

正确的写法为：

```

this.getServletContext().getRequestDispatcher("/a/a.jsp").forward(request, response);
response.sendRedirect("路径");

```

1. 该路径可以是相对于服务器根路径，还可以是相对于当前servlet 的路径。（要与上面讲的第一个区别开来）
① 如果路径以斜杠（/）开头，则被解释为相对于服务器根路径。
② 如果没有以斜杠（/）开头，则被解释为相对于当前servlet 的路径。
2. 如果用根路径，那么该根路径所指的是服务器根路径。
如：http://localhost:8080:/demo/ 那么该服务器根路径指的就是 http://localhost:8080/

范例：
程序的目录层次像上面一样，web.xml 配置如下：

```

<servlet>
<servlet-name>TestForward</servlet-name>
<servlet-class>com.accp.servlet.TestForward</servlet-class>
</servlet>
<servlet-mapping>
<servlet-name>TestForward</servlet-name>
<url-pattern>/a/b/TestForward</url-pattern>
</servlet-mapping>

```

那么用下列语句运行：
response.sendRedirect("/a/a.jsp");
出现404 错误：

那是因为用 response.sendRedirect("/a/a.jsp");重定向的时候，这里的斜杠是服务器的根路径，因此
当然找不到请求的资源了。
正确的做法是：
response.sendRedirect("/demo/a/a.jsp");
或者用相对路径（相对于当前servlet）：
response.sendRedirect("../../a/a.jsp");

