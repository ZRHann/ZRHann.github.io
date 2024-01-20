---
title: Powershell 使用conda activate
date: 2024-01-20 13:43:08
tags:
---





安装完anaconda后，使用`conda activate xxx `会报错

```
argument command: invalid choice: 'activate'
```

直接使用`activate xxx`，则环境没有成功导入。

同时，打开powershell的时候会有红色报错：

```
无法加载文件 C:\Users\ZRHan\Documents\WindowsPowerShell\profile.ps1。未对文件 C:\Users\ZRHan\Documents\WindowsPower
Shell\profile.ps1 进行数字签名。无法在当前系统上运行该脚本。有关运行脚本和设置执行策略的详细信息，请参阅 https:/go.micr
osoft.com/fwlink/?LinkID=135170 中的 about_Execution_Policies。
所在位置 行:1 字符: 3
+ . 'C:\Users\ZRHan\Documents\WindowsPowerShell\profile.ps1'
+   ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : SecurityError: (:) []，PSSecurityException
    + FullyQualifiedErrorId : UnauthorizedAccess
```



使用以下ChatGPT解决方案：

1. 在 PowerShell 中输入以下命令来查看当前的执行策略：

```
Get-ExecutionPolicy
```

2. 更改执行策略：

如果你想允许所有 PowerShell 脚本运行（请确保你了解风险），可以设置执行策略为 "Unrestricted"。输入以下命令：

```
Set-ExecutionPolicy Unrestricted
```

可能有其他方法，例如将这个profile.ps1添加为可信任，也许更安全。
