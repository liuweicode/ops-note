---
layout: post
title:  "如何优雅的解决消息转发问题"
date:   2015-10-03
categories: [iOS]
no-post-nav: true
---


#### ObjectiveC如何优雅的解决消息转发问题

很多时候我们需要实现这样一种场景，我们需要继承系统的View，比如UITextField，然后在我们的自定义TextField中拦截UITextFieldDelegate的某些方法，在拦截代码中实现一些自定义逻辑。

如果给我写，我可能会在我们自定义的TextField中再定义一个delegate2,这是一种非常傻瓜的方式，并且需要实现原先系统的UITextFieldDelegate中的所有方法，最近看到我们组里大神写的代码，才知道我真的是图样图森破了。

主要是用到`forwardingTargetForSelector`来做消息转发。这是Objective C运行时（runtime）技术，很强大，我自己测试的示例代码已经放到[github](https://github.com/liuweicode/MessageInterceptorDemo)上了，有了这个，以后就可以做很多工作了，后面还需要深入研究。

最后再说一下里面用到的一段代码，如下：

```
BOOL selector_belongsToProtocol(SEL selector, Protocol * protocol)
{
    for (int optionbits = 0; optionbits < (1 << 2); optionbits++) {
        BOOL required = optionbits & 1;
        BOOL instance = !(optionbits & (1 << 1));
        
        struct objc_method_description hasMethod = protocol_getMethodDescription(protocol, selector, required, instance);
        if (hasMethod.name || hasMethod.types) {
            return YES;
        }
    }
    return NO;
}
```

刚开始看到这个方法整个人有点懵，为什么这么写就能判断出某个Selector是不是某个协议里的方法，后来突然开窍，原来是`protocol_getMethodDescription`方法的后两个参数，是否必须（required），是否是实例方法（instance），两个Bool，总共4种可能，只要其中有一个得到了方法名（hasMethod.name）并且得到了方法类型（hasMethod.types），那么这个方法一定属于这个协议了。

参考：

http://stackoverflow.com/questions/3498158/intercept-objective-c-delegate-messages-within-a-subclass

#### TODO

深入了解`forwardingTargetForSelector`的消息转发机制。
