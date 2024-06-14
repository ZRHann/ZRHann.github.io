---
title: Docker / docker-compose设置代理
date: 2024-06-14 16:26:20
tags:
---



尝试了很多方法才找到有效的，记录一下。

**创建或编辑 Docker 的配置文件**： 在 `/etc/systemd/system/docker.service.d/` 目录下创建或编辑 `http-proxy.conf` 文件（如果文件不存在则创建它）：

```
sudo mkdir -p /etc/systemd/system/docker.service.d
sudo nano /etc/systemd/system/docker.service.d/http-proxy.conf
```



**在配置文件中添加以下内容**： 如果您的代理服务器运行在本地，地址是 `127.0.0.1` 或 `172.17.0.1`，根据您的实际配置选择其中一个：

```
[Service]
Environment="HTTP_PROXY=http://127.0.0.1:7890"
Environment="HTTPS_PROXY=http://127.0.0.1:7890"
```



**重新加载和重启 Docker 服务**： 保存文件后，重新加载 systemd 配置并重启 Docker 服务：

```
sudo systemctl daemon-reload
sudo systemctl restart docker
```



**检查配置是否生效：**可以通过查看 Docker 服务的环境变量来确认代理配置是否生效：

```
sudo systemctl show --property=Environment docker
```
