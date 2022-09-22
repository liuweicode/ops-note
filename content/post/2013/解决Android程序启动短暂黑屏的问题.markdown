---
layout: post
title:  解决Android程序启动短暂黑屏的问题
date:   2013-02-04
categories: [Android]
no-post-nav: true
---

在AndroidManifest.xml中，将最先启动的Activity设置为android:theme="@android:style/Theme.Translucent"，如下：

```
<activity android:name=".ui.LoginActivity" android:theme="@android:style/Theme.Translucent" android:screenOrientation="portrait" android:launchMode="singleTask">
<intent-filter>
<action android:name="android.intent.action.MAIN" />
<category android:name="android.intent.category.LAUNCHER" />
</intent-filter>
</activity>
```

当然如果你想去掉标题并且全屏，可以在styles.xml中自定义样式，将parent设置为@android:style/Theme.Translucent，如下：

```
<style name="appStrat" parent="@android:style/Theme.Translucent"> 
<item name="android:windowNoTitle">true</item> 
<item name="android:windowFullscreen">true</item> 
</style>
```