---
title: 小米路由器r1d刷机遇到的坑
date: 2024-02-23 16:38:51
tags:
---



刷的是freshtomato，参考了http://beyondlogic.top/index.php/archives/3/以及恩山的几篇博客。

在cfe upload的时候，报错

```
The file transferred is not a valid firmware image.
```

后来发现上传的不是zip，而是解压后的trx文件。



刷不成功，就重启多试几次。即使ping -t通了，也可能还没刷完。

快刷完的时候，指示灯变红，路由器风扇轰鸣，有点吓人。

刷完指示灯是黄色的。

