---
layout: post
title:  制作Gif动画
date:   2013-02-01
categories: [Tool]
no-post-nav: true
---

1,首先使用ffmpeg将视频转换成帧图片

```
liuwei@IT:~/make gif$ ls
temp 人再囧途之泰囧BD.rmvb
liuwei@IT:~/make gif$ ffmpeg -i 人再囧途之泰囧BD.rmvb -r 1 -f image2 temp/%05d.png
liuwei@IT:~/make gif$ cd temp/
liuwei@IT:~/make gif/temp$ ls
00001.png 00004.png 00007.png 00010.png 00013.png 00016.png 00019.png
00002.png 00005.png 00008.png 00011.png 00014.png 00017.png
00003.png 00006.png 00009.png 00012.png 00015.png 00018.png
liuwei@IT:~/make gif/temp$ 
```

2，使用mogrify将图片缩小到合适的尺寸

```
mogrify -resize 178x100 *.png
```

3，使用convert将图片制作成gif

```
liuwei@IT:~/make gif/temp$ convert -delay 0 *.png -loop 0 test.gif
liuwei@IT:~/make gif/temp$ ls | grep *.gif
test.gif
```

![image](https://static.liuwei.co/20130201/test.gif)

参考：
http://blog.csdn.net/huangxiansheng1980/article/details/6820866
http://blog.csdn.net/tge7618291/article/details/7553807
