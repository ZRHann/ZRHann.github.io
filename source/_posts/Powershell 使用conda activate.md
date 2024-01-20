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



这个错误是因为你的 PowerShell 执行策略设置阻止了未签名的脚本运行。Windows PowerShell 默认的执行策略是 "Restricted"，这意味着不允许任何脚本运行。为了解决这个问题，你可以更改 PowerShell 的执行策略，但请注意，这可能会对系统安全产生影响。

可以采取以下步骤来更改执行策略：

1. **以管理员身份运行 PowerShell**：

   - 在 Windows 搜索栏中输入 "PowerShell"。
   - 右键点击 "Windows PowerShell"，选择 "以管理员身份运行"。

2. **查看当前的执行策略**：

   - 在 PowerShell 中输入以下命令来查看当前的执行策略：

     ```
     powershellCopy code
     Get-ExecutionPolicy
     ```

3. **更改执行策略**：

   - 如果你想允许所有 PowerShell 脚本运行（请确保你了解风险），可以设置执行策略为 "Unrestricted"。输入以下命令：

     ```
     powershellCopy code
     Set-ExecutionPolicy Unrestricted
     ```

   - 如果你只想对当前用户更改策略，可以使用：

     ```
     powershellCopy code
     Set-ExecutionPolicy Unrestricted -Scope CurrentUser
     ```

   - 另一个选择是使用 "RemoteSigned" 执行策略，该策略允许本地脚本运行，但要求从 Internet 下载的脚本必须有可信的签名：

     ```
     powershellCopy code
     Set-ExecutionPolicy RemoteSigned
     ```

4. **确认更改**：

   - 当系统提示你确认执行策略更改时，输入 `Y` 并回车以确认。

5. **重新打开 PowerShell**：

   - 更改执行策略后，关闭并重新打开 PowerShell。

更改执行策略可以解决无法运行脚本的问题，但请确保你了解更改执行策略可能带来的安全风险。只运行来自可信来源的脚本，避免执行未经审核的脚本。



可能有其他方法，例如将这个profile.ps1添加为可信任，也许更安全。
