# frp

[frp](https://github.com/fatedier/frp) 是一个高性能的反向代理应用，专注于内网穿透，支持 TCP、UDP、HTTP、HTTPS 等多种协议。

## 镜像

| 镜像 | 说明 |
|:-----|:-----|
| `ghcr.io/ybbapp/frpc` | frp 客户端 |
| `ghcr.io/ybbapp/frps` | frp 服务端 |

## 标签

- `latest` — 跟踪上游最新 Release
- `v<version>` — 对应上游版本号，如 `v0.68.1`

## 使用

### frpc (客户端)

```bash
docker run -d --restart=always --name frpc \
  -v /path/to/frpc.toml:/etc/frp/frpc.toml \
  ghcr.io/ybbapp/frpc:latest -c /etc/frp/frpc.toml
```

### frps (服务端)

```bash
docker run -d --restart=always --name frps \
  -v /path/to/frps.toml:/etc/frp/frps.toml \
  -p 7000:7000 -p 7500:7500 \
  ghcr.io/ybbapp/frps:latest -c /etc/frp/frps.toml
```

## 构建方式

Release 模式 — 从 [GitHub Releases](https://github.com/fatedier/frp/releases) 下载预编译二进制，基于 `alpine:3` 打包。

## 构建触发

- 每日 UTC 08:00（北京时间 16:00）自动检查新版本
- 支持手动触发，可指定版本号
- 已存在的版本不会重复构建
