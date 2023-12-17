---
title: 常用git操作
date: 2023-12-17 22:00:50
tags:
---



### 推送到远程仓库

```
git add .
git commit -m "提交信息"
git push origin main
```



### 版本回退

```
git log
git reset --hard 版本号
```



### 强制push（如回退远程仓库版本）

```
git push origin main --force
```



### 版本反做（即回退到x版本，但不删除x后的版本）

```
git revert -n 版本号
git commit -m "提交信息"
git push origin main
```

