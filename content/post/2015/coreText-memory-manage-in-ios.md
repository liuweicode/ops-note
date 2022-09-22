---
layout: post
title:  CoreText的内存管理
date:   2015-10-04
categories: [iOS,内存管理]
no-post-nav: true
---

### CoreText的内存管理

> 首先我要说明的是,我并没有在官方文档中查到有明确指出ARC情况下使用CoreText需要手动管理内存，如果有人查到具体文档，请告知我。但是基于以下几点，我仍然坚信，我们是需要手动释放的。

#### 一，引起关注的原因：

之前看到一段代码，隐隐感觉CTFontRef并没有释放。

```
for (int i=0; i < array.count; i++) {
	IFAAttributeModel* model = [array objectAtIndex:i];
	if ([model isKindOfClass:[IFAAttributeModel class]]) {
		if (model.string == nil) {
			continue;
		}
		NSInteger currentLength = [model.string length];
		CTFontRef font = CTFontCreateWithName(CFSTR("Helvetica"), model.fontSize, NULL);
		[totalAttr addAttribute:(id)kCTFontAttributeName value:(__bridge id)font range:NSMakeRange(lastIndex, currentLength)];
		[totalAttr addAttribute:(NSString*)NSForegroundColorAttributeName value:model.color range:NSMakeRange(lastIndex, currentLength)];
		lastIndex = lastIndex + currentLength;
	}
}

```

#### 二，验证自己的想法

1,根据[维基百科](https://en.wikipedia.org/wiki/Core_Text)上的解释，Core Text是Core Foundation风格的API，而Core Foundation是不受ARC管理的，因此我们需要手动管理内存。并且在它下面的Example中，是对CTFontRef进行CFRelease的。

```
// Prepare font
CTFontRef font = CTFontCreateWithName(CFSTR("Times"), 48, NULL);

// Create an attributed string
CFStringRef keys[] = { kCTFontAttributeName };
CFTypeRef values[] = { font };
CFDictionaryRef attr = CFDictionaryCreate(NULL, (const void **)&keys, (const void **)&values,
					  sizeof(keys) / sizeof(keys[0]), &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
CFAttributedStringRef attrString = CFAttributedStringCreate(NULL, CFSTR("Hello, World!"), attr);
CFRelease(attr);

// Draw the string
CTLineRef line = CTLineCreateWithAttributedString(attrString);
CGContextSetTextMatrix(context, CGAffineTransformIdentity);  //Use this one when using standard view coordinates
//CGContextSetTextMatrix(context, CGAffineTransformMakeScale(1.0, -1.0)); //Use this one if the view's coordinates are flipped

CGContextSetTextPosition(context, 10, 20);
CTLineDraw(line, context);

// Clean up
CFRelease(line);
CFRelease(attrString);
CFRelease(font);

```
2, 对于Core Foundation的内存管理，苹果有[明确的规则](https://developer.apple.com/library/mac/documentation/CoreFoundation/Conceptual/CFMemoryMgmt/Concepts/Ownership.html#//apple_ref/doc/uid/20001148-CJBEJBHH)，对于方法名有着约定俗成的规则，如下：

There are many ways in which you can get a reference to an object using Core Foundation. In line with the Core Foundation ownership policy, you need to know whether or not you own an object returned by a function so that you know what action to take with respect to memory management. Core Foundation has established a naming convention for its functions that allows you to determine whether or not you own an object returned by a function. In brief, if a function name contains the word "Create" or "Copy", you own the object. If a function name contains the word "Get", you do not own the object. These rules are explained in greater detail in The Create Rule and The Get Rule.

3, 查看Apple的[Sample Code](https://developer.apple.com/library/prerelease/mac/samplecode/CoreTextRTF/Introduction/Intro.html#//apple_ref/doc/uid/DTS40007772-Intro-DontLinkElementID_2)的代码，也是对CTFontRef进行了释放。

4, 最后我们做一个demo来验证

新建一个`Single View Application`的xcode项目，在ViewController.m文件中模拟之前的代码编写一个如下的方法：

```
-(void)test
{
    NSMutableAttributedString* totalAttr = [[NSMutableAttributedString alloc]initWithString:@"1234567890"];
    
    CTFontRef font = CTFontCreateWithName(CFSTR("Helvetica"), 24, NULL);
    
    NSLog(@"%li",CFGetRetainCount(font));
    
    id oFont = (__bridge id)font;
    
    NSLog(@"%li",CFGetRetainCount(font));
    
    [totalAttr addAttribute:(id)kCTFontAttributeName value:oFont range:NSMakeRange(0, 2)];
    
    NSLog(@"%li",CFGetRetainCount(font));

}

```

然后在`viewDidLoad`方法中添加如下代码：

```
dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        while (YES) {
            [self test];
        }
    });
```

按快捷键command＋r运行项目。在Debug Navigator中可以看到Memory一直在持续的上涨。

现在我们在test方法最下面添加释放代码：

```
CFRelease(font);
```

再次command+r运行，可以看到此时Memory并没有持续上涨。


综上所述，我们需要对CTFontCreateWithName创建的CTFontRef进行CFRelease释放操作。

> 其实解决这个问题还有一种方式，将是将`__bridge`换成`__bridge_transfer`,这样就不需要手动`CFRelease`了，代码如下：

```
 -(void)test
{
    NSMutableAttributedString* totalAttr = [[NSMutableAttributedString alloc]initWithString:@"1234567890"];
    
    CTFontRef font = CTFontCreateWithName(CFSTR("Helvetica"), 24, NULL);
    
    NSLog(@"%li",CFGetRetainCount(font));
    
    id oFont = (__bridge_transfer id)font;
    
    NSLog(@"%li",CFGetRetainCount(font));
    
    [totalAttr addAttribute:(id)kCTFontAttributeName value:oFont range:NSMakeRange(0, 2)];
    
    NSLog(@"%li",CFGetRetainCount(font));
}
```
编译运行，内存也没有持续上涨，这主要得益于`__bridge_transfer`将Core Foundation的对象转换为Objective-C对象的同时将对象的内存管理权交给了ARC，ARC帮我们release了。

参考：

https://developer.apple.com/library/prerelease/mac/samplecode/CoreTextRTF/Introduction/Intro.html

https://developer.apple.com/legacy/library/samplecode/CoreTextTest/Listings/main_c.html#//apple_ref/doc/uid/DTS10004140-main_c-DontLinkElementID_4

https://en.wikipedia.org/wiki/Core_Text

http://clang.llvm.org/docs/AutomaticReferenceCounting.html#bridged-casts

http://www.yifeiyang.net/development-of-the-iphone-simply-6/

http://blog.sina.com.cn/s/blog_6dce99b10101kux4.html


