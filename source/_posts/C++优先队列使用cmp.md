---
title: C++优先队列使用cmp
date: 2023-12-15 19:06:52
tags:
---

```cpp
struct cmp
{
    bool operator()(const node &a,const node &b)
    {
        return a.x > b.x;
    }
};

priority_queue<node,vector<node>,cmp > q4;
```

参考：https://www.acwing.com/blog/content/394/
