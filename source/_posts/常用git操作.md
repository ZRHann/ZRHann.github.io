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



### 添加已push文件到`.gitignore`

额外地，

```
git rm --cached 文件名
# 如果是文件夹，则添加 -r 选项
git rm --cached -r 文件夹名
```

然后commit并push。
