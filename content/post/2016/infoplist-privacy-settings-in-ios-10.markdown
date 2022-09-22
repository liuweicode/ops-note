---
layout: post
title:  "iOS10请求隐私权限的设置 - Info.plist"
date:   2016-12-24
categories: [Error, Info.plist, iOS, iOS 10, Privacy Settings, Swift 2.3, Swift 3.0, Xcode 8.0]
no-post-nav: true
---

在访问用户手机通讯录,相册,地址,日历等隐私数据前需要向用户请求使用权限，在iOS10中，苹果公司加强了对隐私控制的审查，你必须在`Info.plist`文件中对所有需要访问的隐私数据作出声明。

![Image](https://static.liuwei.co/20161224/ios10.png)

##### 哪些`framework`在`Info.plist`中有`privacy key`：

Calendar , Contact , Reminder , Photo , Bluetooth Sharing , Microphone , Camera , Location , Heath , HomeKit , Media Library , Motion , CallKit , Speech Recognition , SiriKit , TV Provider.

##### 如果不提供`privacy key`会报什么错误：

如果你不在`Info.plist`中提供指定的`privacy key`，你的应用程序会没有任何商量余地的直接崩溃！以下是崩溃日志：

```
The app has crashed because it attempted to access privacy-sensitive data without a usage description. The app's Info.plist must contain an NSCalendarsUsageDescription key with a string value explaining to the user how the app user how the app uses this data.
```

##### 如何解决这个错误呢:

当然是根据你相应的请求在Info.pist中给出相应的privacy key啦。

![Image](https://static.liuwei.co/20161224/privacykeys.png)

**`Calendar :`**
Key      :  Privacy - Calendars Usage Description    
Value  :  $(PRODUCT_NAME) calendar events

**`Reminder :`**
Key      :   Privacy - Reminders Usage Description    
Value  :   $(PRODUCT_NAME) reminder use

**`Contact :`**
Key       :   Privacy - Contacts Usage Description     
Value    :  $(PRODUCT_NAME) contact use

**`Photo :`**
Key       :  Privacy - Photo Library Usage Description    
Value   :  $(PRODUCT_NAME) photo use

**`Bluetooth Sharing :`**
Key       :  Privacy - Bluetooth Peripheral Usage Description     
Value   :  $(PRODUCT_NAME) Bluetooth Peripheral use

**`Microphone :`**
Key        :  Privacy - Microphone Usage Description    
Value    :  $(PRODUCT_NAME) microphone use

**`Camera :`**
Key       :  Privacy - Camera Usage Description   
Value   :  $(PRODUCT_NAME) camera use

**`Location :`**
Key      :  Privacy - Location Always Usage Description   
Value  :  $(PRODUCT_NAME) location use

Key       :  Privacy - Location When In Use Usage Description   
Value   :  $(PRODUCT_NAME) location use

**`Heath :`**
Key      :  Privacy - Health Share Usage Description   
Value  :  $(PRODUCT_NAME) heath share use

Key      :  Privacy - Health Update Usage Description   
Value  :  $(PRODUCT_NAME) heath update use

**`HomeKit :`**
Key      :  Privacy - HomeKit Usage Description   
Value  :  $(PRODUCT_NAME) home kit use

**`Media Library :`**
Key      :  Privacy - Media Library Usage Description   
Value  :  $(PRODUCT_NAME) media library use

**`Motion :`**
Key      :  Privacy - Motion Usage Description   
Value  :  $(PRODUCT_NAME) motion use

**`Speech Recognition :`**
Key      :  Privacy - Speech Recognition Usage Description   
Value  :  $(PRODUCT_NAME) speech use

**`SiriKit  : `**
Key      :  Privacy - Siri Usage Description  
Value  :  $(PRODUCT_NAME) siri use

**`TV Provider : `**
Key      :  Privacy - TV Provider Usage Description   
Value  :  $(PRODUCT_NAME) tvProvider use

谢谢阅读

原文链接: [https://iosdevcenters.blogspot.com/2016/09/infoplist-privacy-settings-in-ios-10.html](https://iosdevcenters.blogspot.com/2016/09/infoplist-privacy-settings-in-ios-10.html)
