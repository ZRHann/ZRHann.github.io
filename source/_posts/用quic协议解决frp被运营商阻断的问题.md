---
title: 用quic协议解决frp被运营商阻断的问题
date: 2024-07-15 03:00:15
tags:
---



tcp的frp会被运营商阻断。测试环境：frps、frpc均为0.59.0版本，frps在国内阿里云（无备案），frpc在frps同一台机器、azure新加坡都可以正常连接，但在校园网windows、校园网linux、移动云电脑linux无法连接，报错：

```
login to the server failed: i/o deadline reached. With loginFailExit enabled, no additional retries will be attempted
```

推测是被运营商阻断。

解决方法是使用quic协议。主要是设置frps的`quicBindPort`（可以和`bindPort`相同），以及frpc的 `transport.protocol = "quic"`。

另外由于quic是基于udp的（？），所以记得开放服务器安全组的udp协议端口。

配置文件：

```toml
# frpc.toml
serverAddr = "xxx"
serverPort = 27000
auth.method = "token"
auth.token = "xx"
transport.protocol = "quic"

[[proxies]]
name = "ssh"
type = "tcp"
localIP = "127.0.0.1"
localPort = 22
remotePort = 10001

[[proxies]]
name = "test2"
type = "tcp"
localIP = "127.0.0.1"
localPort = 222
remotePort = 10001
```

```toml
# frps.toml
bindPort = 27000
quicBindPort = 27000
auth.method = "token"
auth.token = "xx"

# Server Dashboard，可以查看frp服务状态以及统计信息
webServer.addr = "0.0.0.0" # 后台管理地址
webServer.port = 7500 # 后台管理端口
webServer.user = "xx" # 后台登录用户名
webServer.password = "xx" # 后台登录密码
```

