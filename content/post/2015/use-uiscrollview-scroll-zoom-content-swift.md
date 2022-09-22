---
layout: post
title:  UIScrollView 教程（swift）
date:   2015-08-18
categories: [tutorial, translation, UIScrollView, iOS]

---

UIScrollView 在ios开发中是非常有用的控件之一。它是UITableView的基础，并且是展示内容大于屏幕的一种非常好的方式。在这篇UIScrollView教程中，你将学到这个控件的如下使用方法：

- 如何使用一个UIScrollView展示一张大图。
- 当缩放UIScrollView的时候，如何保持UIScrollView的content居中。
- 如何嵌入复杂的视图到UIScrollView。
- 如何使用UIScrollView的可翻页特性，如何配合UIPageControl，进行滚动翻页显示。
- 如何显示当前页的时候能够看到上一页/下一页的内容。
- 还有更多！

这篇教程假定你熟悉swift和ios编程。如果你是一个新手，也许你希望从本网站了解一些[其他教程](http://www.raywenderlich.com/?page_id=2519)。

同样，这篇教程也假定你知道怎么使用Interface Builder来添加新控件到一个View上，并在你的代码和Storybard之间进行连接。在继续之前你需要熟悉Storyboards，所以如果你对Storyboards或者Interface Builder不熟悉，你需要在本站看看这些[Storyboards教程](http://www.raywenderlich.com/?p=5138)

## 开始

打开Xcode创建一个新的项目，选择`File\New\Project…`,然后选择`iOS\Application\Single View Application`模板，在product name输入`ScrollViews`，在language一栏选择Swift，然后在devices上选择`iPhone`.

![image](https://static.liuwei.co/20150818/Create_Project-700x413.png)

点击`Next`,然后选择一个目录存放你的项目。

然后，为这个项目[下载资源](http://cdn1.raywenderlich.com/downloads/ScrollViewsResources.zip)，然后拖动解压后的文件到项目根目录，确保`"Copy items if needed"`复选框是选中状态。

![image](https://static.liuwei.co/20150818/Copy_Resources-700x412.png)

由于这篇教程打算阐明scroll view的四个用法，这个项目将用一个四个选项的tableview菜单，每一个选项将打开一个新的view controller来显示scroll view的某一用法。

当你完成后，应该类似下面的样子：

![image](https://static.liuwei.co/20150818/Storyboard_Overall-655x500.png)

构建tableview菜单，需要以下步骤：

1. 打开Main.storyboard，删除已经存在的view controller
2. 这篇教程关闭了Auto Layout。从Utilities面板，选择File Inspector，然后取消Use Auto Layout复选框，在弹出框上，确保“Keep size class data for:”是选择了iPhone，然后选择Disable Size Classes按钮。   

![image](https://static.liuwei.co/20150818/Disable_Size_Classes.png)

3. 下一步，在storyboard上添加一个`Table View Controller`。
4. 现在，选中你添加的table，然后选择`Editor\Embed In\Navigation Controller`.
5. 选中新的Navigation Controller，然后在Attributes inspector上选中`Is Initial View Controller`复选框。
6. 在table view controller上选择table view，然后在attributes inspector设置content type为静态单元格`Static Cells`（如下图所示）。   

![image](https://static.liuwei.co/20150818/Static_Cells.png)

7. 在storyboard层级上，在文档大纲上点击Table View左边的箭头，然后选中`Table View Section`。在inspector，设置行的数量为4.   

![image](https://static.liuwei.co/20150818/UIScrollView-table-view-section.png)

8. table view的每一行，设置style为`Basic`,然后编辑labels内容如下：
- Image Scroll
- Custom View Scroll
- Paged
- Paged with Peeking

> 
备注：当你设置每个table row的style为“Basic”，table row将得到一个额外的子控件 － label，你需要再次展开它来编辑他们。


保存storyboard，然后编译运行。你会看到你的table view，类似下面的图片，遗憾的事，此时此刻tableview还没有任何东西，但是你可以修复它！

![image](https://static.liuwei.co/20150818/Scroll_View_Run_11-281x500.png)

## 滚动和缩放一张大图

你需要学习的第一件事是如何设置一个scroll view，允许用户缩放和平移。

首先，你需要一个建立一个view controller。打开`ViewController.swift`， 然后在顶部定义类的地方，让他实现`UIScrollViewDelegate`协议。

```
class ViewController: UIViewController, UIScrollViewDelegate {
```

在类定义的内部，添加下面的outlet属性：

```
@IBOutlet var scrollView: UIScrollView!
```

下一步你需要连接这个属性到真实的scroll view。

打开storyboard，并且从对象库中拖动一个`View Controller`到画布，选中这个新的view controller，并且在Identity Inspector上设置class为`ViewController`.

![image](../images/View_controller_class-_type.png)

这个view controller将显示一个图片事例。从table view的`Image Scroll`行上按住control键单击，然后拖动到新的view controller。在弹出的菜单上,选择`Selection Segue`下的`Push`选项。这样，当用户选择第一行，view controller被推到了navigation的栈上。

从对象库里拖动一个`Scroll View`填充到view controller上。

![image](../images/Add_Scroll_View-293x500.png)

把scroll view连接到view controller，并且把scroll view的代理（delegate）设置为view controller。

![image](../images/Scroll_View_Outlets.png)

现在，你需要坐下来并且编写你的代码，打开`ViewController.swift`,并且添加一个新的属性：

```
var imageView: UIImageView!
```

这将在用户四处滚动的时候持有image view。

现在，是时候设置scroll view最有趣的部分了。用以下代码替换`viewDidLoad`：

```
override func viewDidLoad() {
  super.viewDidLoad()
 
  // 1
  let image = UIImage(named: "photo1.png")!
  imageView = UIImageView(image: image)
  imageView.frame = CGRect(origin: CGPoint(x: 0, y: 0), size:image.size)
  scrollView.addSubview(imageView)
 
  // 2
  scrollView.contentSize = image.size
 
  // 3
  var doubleTapRecognizer = UITapGestureRecognizer(target: self, action: "scrollViewDoubleTapped:")
  doubleTapRecognizer.numberOfTapsRequired = 2
  doubleTapRecognizer.numberOfTouchesRequired = 1
  scrollView.addGestureRecognizer(doubleTapRecognizer)
 
  // 4
  let scrollViewFrame = scrollView.frame
  let scaleWidth = scrollViewFrame.size.width / scrollView.contentSize.width
  let scaleHeight = scrollViewFrame.size.height / scrollView.contentSize.height
  let minScale = min(scaleWidth, scaleHeight);
  scrollView.minimumZoomScale = minScale;
 
  // 5
  scrollView.maximumZoomScale = 1.0
  scrollView.zoomScale = minScale;
 
  // 6
  centerScrollViewContents()
}
```

这似乎看起来有些复杂，所以让我们一步一步分解它。你会觉得它并没有那么糟糕。

1. 首先，你需要用你之前添加到项目的`photo1.png`图片创建一个image view，这里强制解包表示如果它找不到photo1.png图片则会崩溃。这会早点提醒你不要忘记添加那个文件到项目中。下一步，你设置image view的frame（它的大小和位置），让他位于父视图的(0,0)坐标点和它的尺寸，最后，添加image view作为scroll view的子视图。
2. 你需要告诉scroll view的contentsize，让它知道可以横向纵向可以滚动多远，在当前这个例子，它的contentsize是图片的size。
3. 这里设置双击放大手势，你不需要`UIPinchGestureRecognizer`来放大，因为UIScrollView已经内置有一个了！
4. 下一步，你需要为scroll view计算出最小缩放，一个zoom scale表示content被正常显示的大小，小于1的zoom scale显示缩小内容，大于1的zoom scale显示放大的内容。获取最小的zoom scale，你基于它的宽度计算需要缩小多少让图片正好适配scroll view的边界。然后你需要针对图片的高度作出同样的计算，那两个最小的计算结果是scroll view的最小缩放。当完全缩小你可以看见全部的图片。
5. 你设置最大缩放为1，因为放到比图片的分辨率还大会引起图片模糊，你设置初始缩放为最小，让图片已开始完全缩小。
6. 调用一个帮助方法让图片在scroll view居中，帮助方法在哪里，下面就来讲。

添加`centerScrollViewContents`的实现到类中：

```
func centerScrollViewContents() {
  let boundsSize = scrollView.bounds.size
  var contentsFrame = imageView.frame
 
  if contentsFrame.size.width < boundsSize.width {
    contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0
  } else {
    contentsFrame.origin.x = 0.0
  }
 
  if contentsFrame.size.height < boundsSize.height {
    contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0
  } else {
    contentsFrame.origin.y = 0.0
  }
 
  imageView.frame = contentsFrame
}
```

这个方法的关键是解决一个小问题：如果scroll view的contentsize比它的边界小，然后它位于左上角，而不是在中心，如果你允许用户完全缩小，如果图片在视图中心将是极好的。这个方法实现了让图片始终在scroll view边界的中心。

最后，添加`scrollViewDoubleTapped`的实现到类中，实现双击手势。

```
func scrollViewDoubleTapped(recognizer: UITapGestureRecognizer) {
  // 1        
  let pointInView = recognizer.locationInView(imageView)
 
  // 2
  var newZoomScale = scrollView.zoomScale * 1.5
  newZoomScale = min(newZoomScale, scrollView.maximumZoomScale)
 
  // 3
  let scrollViewSize = scrollView.bounds.size
  let w = scrollViewSize.width / newZoomScale
  let h = scrollViewSize.height / newZoomScale
  let x = pointInView.x - (w / 2.0)
  let y = pointInView.y - (h / 2.0)
 
  let rectToZoomTo = CGRectMake(x, y, w, h);
 
  // 4
  scrollView.zoomToRect(rectToZoomTo, animated: true)
}
```

当双击的时候这个方法被调用，下面一步一步指导发生了什么：

1. 首先，你需要知道在图片控件的哪里被点击了，你需要直接在那个点上放大，这或许是作为一个用户所期望的。
2. 下一步，你计算一个zoom scale让它放大150%，但是超过了你在`viewDidLoad`里面定义的最大缩放。
3. 然后使用第一步的位置来计算一个用来放大的`CGRect`矩形。
4. 最后，你需要告诉scroll view放大，并且这里你需要让他看起来有一个不错的动画。

> 关于ios不同手势的更多信息，查看[UIGestureRecognizer tutorial](http://www.raywenderlich.com/?p=76020)

现在，还记住你是如何设置`ViewController`作为`UIScrollViewDelegate`的吗？是的，现在你需要实现那个协议里面的一些方法。添加下面的方法到类中：

```
func viewForZoomingInScrollView(scrollView: UIScrollView!) -> UIView! {
  return imageView
}
```

这是scroll view缩放机制的核心，它告诉scroll view当捏放的时候哪个视图需要变的更大或者更小。所以告诉它是`imageView`.

最后，添加下面的代理方法到类中：

```
func scrollViewDidZoom(scrollView: UIScrollView!) {
  centerScrollViewContents()
}
```

当用户完成缩放scroll view将调用这个方法，这里，你需要view重新放到中心，scroll view不会自然的出现放大，取而代之的是，它会排在左上角。

现在，深呼吸，给你自己拍拍后背，编译并且运行你的项目！如果一切顺利，在`scroll view`上单击。你最终会有一个完美的可以缩放，移动和单击的图片，太棒了！

![image](../images/Scroll_View_Run_2-281x500.png)

## 滚动和缩放一个有层级的视图


如果你希望在你的scroll view里面放多个视图，而不仅仅是一张图片，如果你有一个复杂的层级视图需要可以被缩放和移动，当然，scroll view可以做到这些！更重要的是，它在你已经完成的基础上仅仅需要一小步。

创建一个新文件，选择` iOS\Source\Cocoa Touch Class `模板。设置class名为`CustomScrollViewController`，然后设置为`UIViewController`的子类，确保“Also create XIB file” 复选框没有选中，设置语言为`swift`.点击`Next`然后保存到项目里。

打开`CustomScrollViewController.swift`,然后用下面的内容替换：

```
import UIKit
 
class CustomScrollViewController: UIViewController, UIScrollViewDelegate {
  @IBOutlet var scrollView: UIScrollView!
 
}
```

下一步，打开`Main.storyboard`,像刚刚一样添加`View Controller`并从table view的第二行连线。设置view controller的class为你刚刚创建的`CustomScrollViewController`.

添加一个`Scroll View`并且连接它到outlet，并且像刚刚一样设置view controller作为它的代理。

然后，打开`CustomScrollViewController.swift`并且在scrollView outlet下面的添加属性：

```
var containerView: UIView!
```

与之前不同的是containerView替代了`UIImageView`,它是怎样工作的应该是一个小小的提示。

现在，像这样实现`viewDidLoad`：

```
override func viewDidLoad() {
  super.viewDidLoad()
 
  // Set up the container view to hold your custom view hierarchy
  let containerSize = CGSize(width: 640.0, height: 640.0)
  containerView = UIView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size:containerSize))
  scrollView.addSubview(containerView)
 
  // Set up your custom view hierarchy
  let redView = UIView(frame: CGRect(x: 0, y: 0, width: 640, height: 80))
  redView.backgroundColor = UIColor.redColor();
  containerView.addSubview(redView)
 
  let blueView = UIView(frame: CGRect(x: 0, y: 560, width: 640, height: 80))
  blueView.backgroundColor = UIColor.blueColor();
  containerView.addSubview(blueView)
 
  let greenView = UIView(frame: CGRect(x: 160, y: 160, width: 320, height: 320))
  greenView.backgroundColor = UIColor.greenColor();
  containerView.addSubview(greenView)
 
  let imageView = UIImageView(image: UIImage(named: "slow.png"))
  imageView.center = CGPoint(x: 320, y: 320);
  containerView.addSubview(imageView)
 
  // Tell the scroll view the size of the contents
  scrollView.contentSize = containerSize;
 
  // Set up the minimum & maximum zoom scales
  let scrollViewFrame = scrollView.frame
  let scaleWidth = scrollViewFrame.size.width / scrollView.contentSize.width
  let scaleHeight = scrollViewFrame.size.height / scrollView.contentSize.height
  let minScale = min(scaleWidth, scaleHeight)
 
  scrollView.minimumZoomScale = minScale
  scrollView.maximumZoomScale = 1.0
  scrollView.zoomScale = 1.0
 
  centerScrollViewContents()
}
```

`viewDidLoad`设置一个视图作为视图层级的根视图。这就是之前设置的实力变量`containerView`。然后添加这个根视图到scroll view。这是关键，如果你打算让view被放大，只能有一个view可以被添加到scroll view。因为正如你将回调的，你在代理的回调方法`viewForZoomingInScrollView`只能返回一个视图。你设置`zoomScale`为1代替`minScale`,使contentview正常大小，代替屏幕大小。

同样的，实现`centerScrollViewContents`和两个`UIScrollViewDelegate`的代理方法。对于原先的版本，用`containerView`取代`imageView`.

```
func centerScrollViewContents() {
  let boundsSize = scrollView.bounds.size
  var contentsFrame = containerView.frame
 
  if contentsFrame.size.width < boundsSize.width {
    contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0
  } else {
    contentsFrame.origin.x = 0.0
  }
 
  if contentsFrame.size.height < boundsSize.height {
    contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0
  } else {
    contentsFrame.origin.y = 0.0
  }
 
  containerView.frame = contentsFrame
}
 
func viewForZoomingInScrollView(scrollView: UIScrollView!) -> UIView! {
  return containerView
}
 
func scrollViewDidZoom(scrollView: UIScrollView!) {
  centerScrollViewContents()
}
```

> 备注：你可能留意到了`UITapGestureRecognizer`的不足。这是让这部分教程更简单。随意添加进去作为额外的练习。

现在编译并且运行你的项目，这次，点击`Custom View Scroll`,然后平移和缩放，是不是很棒？

## 可翻页的UIScrollView


原文：[UIScrollView Tutorial: Getting Started](http://www.raywenderlich.com/76436/use-uiscrollview-scroll-zoom-content-swift)
