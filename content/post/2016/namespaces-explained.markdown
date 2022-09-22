---
layout: post
title:  PHP 命名空间说明
date:   2016-12-28
categories: [PHP, namespaces, 命名空间]
no-post-nav: true
---

在PHP5.3版本中新添加了一个命名空间特性,许多现代流行的语言拥有这个特性已经有一段时间了，但是PHP这一特性有一点点姗姗来迟，当然了，每个新的特性都有它存在的意义，让我们看看为什么PHP的`namespace`有利于我们的应用程序。

在PHP中，你不能同时定义一个相同名字的类，类名必须唯一。那么问题来了，如果你使用了一个第三方的库，这个库中有一个`User`类，那么你在创建你自己的类时就不能命名为`User`了。这就尴尬了，因为`User`这个名字太普遍了，对吧？

PHP命名空间帮我们解决了这个问题，实际上我们想创建多少个`User`类就可以创建多少个，不仅仅如此，我们也可以使用命名空间是我们的代码分门别类，或者显示组织结构。

让我们看一眼一个正经的类(类的确是类，正不正经我不知道)，嗯，我知道你曾经这么使用过，相信我这一次吧。（仿佛看见了作者神秘的微笑...）

### 全局命名空间

这是一个极其简单的类.

```
<?php

// app/models/Eddard.php

class Eddard
{

}
```
没有什么特别的，如果我们要使用上面这个类，我们可以这样做：

```
<?php

// app/routes.php

$eddard = new Eddard();
```

> 黛尔, 我感觉我的智商受到了极大的侮辱...

好吧，开玩笑啦，言归正传，我们可以想象这个类是在一个全局的`global`命名空间中。我不清楚这样说是否正确，但是对我而言貌似还是比较合适的，它本质是说，那个类没有命名空间。它只是一个标准的类而已。

### 简单的命名空间

让我们在之前的那个'全局的Eddard'类旁边创建另一个类:

```
<?php

namespace Stark;

// app/models/another.php

class Eddard
{

}
```

这里我们创建了另一个Eddard类，仅仅做了一个小小的修改。添加了一个`namespace`指令，在`namespace Stark`这一行。`namespace`指令告诉PHP我们所有写的代码都是相对于`Stark`命名空间下的。它也表示所有在这个文件中创建的类将被包含在'Stark'命名空间里。

现在，我们再次使用'Stark'类：

```
<?php

// app/routes.php

$eddard = new Eddard();
```

再一次，我们获取到了上个章节创建的类的实例，不是在'Stark'命名空间下的那个实例。下面让我们创建一个'Stark'命名空间下的'Eddard'实例。

```
<?php

// app/routes.php

$eddard = new Stark\Eddard();
```
我们可以采用在命名空间名称中加前缀的方式实例化某个命名空间下的类，在'Stark'和'Eddard'之间用一个反斜杠(\\)来分隔，现在我们有了一个'Stark'命名空间下的'Eddard'实例，腻害了，我的哥！

你需要注意的是，命名空间可以有无限个层级，比如：

```
This\Namespace\And\Class\Combination\Is\Silly\But\Works
```

### 相对论

还记得我曾经告诉过你的，PHP总是运行与当前命名空间相关的文件，好的，下面让我们看看这个特性：

```
<?php

namespace Stark;

// app/routes.php

$eddard = new Eddard();
```
像上面这个实例化的例子，我们添加了命名空间指令，我们将PHP脚本移到了'Stark'命名空间下，现在由于我们在同一个命名空间下，这次我们获取的是'Stark'命名空间下的'Eddard'实例。不用我说了吧，你懂的。

现在我们改变了命名空间，那么，问题来了，你知道是什么问题吗？那就是我们怎么实例化最初的那个'Eddard'类呢，就是那个没有命名空间的，我称它为'全局命名空间'的那个'Eddard'类。

幸运的是，PHP有一个引用全局命名空间下的类的方式，我们只需要简单的加上反斜杠(\\)前缀即可：

```
<?php

// app/routes.php

$eddard = new \Eddard();
```
有了这个主反斜杠(\\),PHP知道引用的是全局命名空间下的'Eddard'类，所以PHP会实例化这个类。

> 原文中 "Use your imagine a little, like how Barney showed you. "这句话我不知道怎么翻译，我Google了一下，Barney应该是美国比较流行的一个电视剧里面的紫色小恐龙。作者应该是想说再多想一点，正如Barney教会你的。当然这是我瞎猜的，如果猜错了，来咬我啊～

![Image](https://static.liuwei.co/20161228/Barney&Friends.jpeg)

咳，咳，当然这并不影响我继续翻译，试想一下，如果我们有一个`Edmure`类在`Tully`命名空间中，我们想在'Stark'命名空间中如何调用？

```
<?php

namespace Stark;

// app/routes.php

$edmure = new \Tully\Edmure();

```
再一次用到了斜杠前缀(\\)，我们需要使用斜杠(\\)前缀，让程序会到全局命名空间中，然后再从'Tully'命名空间实例化该类。

每一次使用完整的层级路径来引用相关的类未免有点折腾人了，幸运的是，有一个不错的快捷方式，使用`use`语句，让我们看看下面的例子：

```
<?php

namespace Stark;

use Tully\Edmure;

// app/routes.php

$edmure = new Edmure();
```
使用`use`语句，我们把一个类引入到当前的命名空间，这样我们在实例化类的时候只需要提供名字就可以了。现在，不要问我为什么它不需要使用反斜杠做前缀，因为我也不知道。这是我所知道的唯一例外，我很抱歉！如果你愿意你可以加上前缀，不过你不需要这么做。

为了弥补这个讨厌的不一致，让我展示给你另外一个巧妙的方式，我们可以给我们导入的类起一个别名。正如我们在PHP playground做的一样，代码如下：

```
<?php

namespace Stark;

use Tully\Brynden as Blackfish;

// app/routes.php

$brynden = new Blackfish();
```

采用`as`关键字，我们给了'Tully/Brynden'类一个叫做'Blackfish'的别名，巧妙的方式，对吧！而且，如果你需要在同一个命名空间下使用两个相同类名的类，这也很有帮助。比如：

```
<?php

namespace Targaryen;

use Dothraki\Daenerys as Khaleesi;

// app/routes.php

class Daenerys
{

}

// Targaryen\Daenerys
$daenerys = new Daenerys();

// Dothraki\Daenerys
$khaleesi = new Khaleesi();
```
通过给'Dothraki'命名空间下的'Daenerys'类一个别名'Khaleesi',我们可以仅仅使用名称就可以调用两个'Daenerys'类了，而不需要加上冗长的命名空间层级。很方便使用，不是吗？这就是为了避免冲突，分门别类的目的。

你想要`use`多少个类，就可以`use`多少个类：

```
<?php

namespace Targaryen;

use Dothraki\Daenerys;
use Stark\Eddard;
use Lannister\Tyrion;
use Snow\Jon as Bastard;
```

### 结构

命名空间不仅仅只是关于避免冲突，我们可以用它来组织代码结构和所有者，让我用另一个栗子来解释一下。

假如我们想创建一个开源库，我喜欢别人使用我的代码，那感觉超屌！问题是，我不想给使用我的库的兄弟们增添有关类名冲突的麻烦，那将是不好使用体验。为了让开源代码友好，易于嵌入，更独立，下面是我如何避免解决这个问题的：

```
Dayle\Blog\Content\Post
Dayle\Blog\Content\Page
Dayle\Blog\Tag
```

这里我用了我的名字作为命名空间来存放源代码，对于使用我的库的人来说也是这么分割我的代码的，在基命名空间`Dayle`下，我创建了一些子命名空间来组织我程序的内部结构。

在composer章节，你将学习到如何使用命名空间来简化你所定义的类，我墙裂推荐你看看这个有用的机制。

### 限制

实际上，起'限制'这个子标题，我感觉有些不妥，我所说的'限制'并不是一个真正的bug。

你知道，在其他语言中，命名空间有相似的实现方式，当不同命名空间之间相互调用的时候，他们提供一个额外的特性来简化操作。

拿Java来举栗吧，你可以使用通配符导入某个命名空间下的所有类，在Java中，`import`关键字相当于这里的`use`,并且它使用点(.)来分割嵌套的命名空间（Java中叫包），下面是个栗子：

```
import dayle.blog.*;
```

这会导入'dayle.blog'包下的所有类。

而在PHP中你做不到，你需要分别导入每一个类。抱歉，实际上，为什么我要说抱歉呢？去向PHP的内部组抱怨啊，不，你需要冷静点，他们已经给了我们许多很酷很有用的东西啦。

然而这里有一个巧妙的技巧，想象我们有这个命名空间和类结构，正如之前的栗子：

```
Dayle\Blog\Content\Post
Dayle\Blog\Content\Page
Dayle\Blog\Tag
```

我们可以给子命名空间起一个别名来使用它下面的类，下面是一个栗子：

```
<?php

namespace Baratheon;

use Dayle\Blog as Cms;

// app/routes.php

$post = new Cms\Content\Post;
$page = new Cms\Content\Page;
$tag  = new Cms\Tag;
```
这对使用同一个命名空间下的许多类很有效，希望你喜欢！

原文链接: [https://daylerees.com/php-namespaces-explained/](https://daylerees.com/php-namespaces-explained/)
