---
title: Spack常用操作
date: 2024-05-07 14:10:24
tags:
---





## 环境配置

```
spack compilers
```

列出可用的编译器列表。



```
spack compiler find
```

添加已有编译器，可以检测系统自带编译器并添加。



```
export SPACK_USER_CONFIG_PATH=/home/team1/zrh/softwares/spack/etc/spack/defaults
```

设置配置文件为只使用自己安装目录的，而不是用户目录 `~/.spack`和系统目录。多人使用同用户的情况下，可以防止干扰。



## 软件安装

```
spack clean -a
```

清除缓存



## 导入到module

```
spack module tcl refresh --delete-tree
```

生成`modulefile`。



```
/home/team1/zrh/softwares/spack/share/spack/modules/linux-debian12-zen3/
```

生成的`modulefile`的位置



```
export MODULEPATH=/home/team1/zrh/softwares/spack/share/spack/modules/linux-debian12-zen3/:$MODULEPATH
```

添加进MODULEPATH。这样`module ava`可以识别到该目录。
