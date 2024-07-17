---
title: 远程服务器无法连接互联网的情况下使用vscode copilot
date: 2024-07-18 05:25:05
tags:
---

https://github.com/orgs/community/discussions/52369#discussioncomment-9920089

Step by step:

`cmd+shift+p` to open the command panel

```
>Preferences: Open Remote Settings (JSON) (SSH: ...)
```

Update the file to

```
{
  "remote.extensionKind": {
    "GitHub.copilot": [
      "ui"
    ],
    "GitHub.copilot-chat": [
      "ui"
    ],
  },
}
```



Save

`cmd+shift+p` to open the command panel

```
>Developer: Reload window
```
