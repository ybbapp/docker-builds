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

## Docker Compose

### frps (服务端)

```yaml
services:
  frps:
    image: ghcr.io/ybbapp/frps:latest
    restart: always
    volumes:
      - ./frps.toml:/etc/frp/frps.toml
    ports:
      - "7000:7000"   # frpc 连接端口
      - "7500:7500"   # Dashboard
      - "6000-6010:6000-6010"  # 代理端口范围（按需调整）
    command: ["-c", "/etc/frp/frps.toml"]
```

`frps.toml` 示例：

```toml
bindAddr = "0.0.0.0"
bindPort = 7000

auth.method = "token"
auth.token = "your-secret-token"

# Dashboard（可选）
webServer.addr = "0.0.0.0"
webServer.port = 7500
webServer.user = "admin"
webServer.password = "admin"

log.to = "console"
log.level = "info"
```

### frpc (客户端)

```yaml
services:
  frpc:
    image: ghcr.io/ybbapp/frpc:latest
    restart: always
    volumes:
      - ./frpc.toml:/etc/frp/frpc.toml
    environment:
      FRP_SERVER_ADDR: "your-server-ip"
      FRP_TOKEN: "your-secret-token"
    command: ["-c", "/etc/frp/frpc.toml"]
```

`frpc.toml` 示例（TCP 代理 SSH）：

```toml
serverAddr = "{{ .Envs.FRP_SERVER_ADDR }}"
serverPort = 7000

auth.method = "token"
auth.token = "{{ .Envs.FRP_TOKEN }}"

log.to = "console"
log.level = "info"

[[proxies]]
name = "ssh"
type = "tcp"
localIP = "127.0.0.1"
localPort = 22
remotePort = 6000
```

## 环境变量

frp 配置文件支持 Go template 语法引用环境变量，格式为 `{{ .Envs.VAR_NAME }}`。

在 Docker Compose 中通过 `environment` 传入，配置文件中通过模板引用，实现配置与敏感信息分离。

常用变量示例：

| 变量 | 说明 | 使用方 |
|:-----|:-----|:-------|
| `FRP_SERVER_ADDR` | frps 服务器地址 | frpc |
| `FRP_TOKEN` | 认证 token | frpc / frps |
| `FRP_SSH_REMOTE_PORT` | SSH 代理远程端口 | frpc |

> [!TIP]
> 环境变量命名无固定要求，只需配置文件中的 `{{ .Envs.XXX }}` 与 `environment` 中的 key 一致即可。

## 配置参考

### frps 主要字段

| 字段 | 默认值 | 说明 |
|:-----|:-------|:-----|
| `bindAddr` | `0.0.0.0` | 监听地址 |
| `bindPort` | `7000` | frpc 连接端口 |
| `auth.method` | `token` | 认证方式（`token` / `oidc`） |
| `auth.token` | — | 共享密钥 |
| `webServer.port` | — | 启用 Dashboard |
| `transport.tls.force` | `false` | 强制 TLS |

### frpc 主要字段

| 字段 | 默认值 | 说明 |
|:-----|:-------|:-----|
| `serverAddr` | — | frps 地址 |
| `serverPort` | `7000` | frps 端口 |
| `auth.token` | — | 需与 frps 一致 |
| `transport.protocol` | `tcp` | 传输协议（`tcp` / `kcp` / `quic` / `websocket`） |

### 代理字段 (`[[proxies]]`)

| 字段 | 说明 |
|:-----|:-----|
| `name` | 代理名称（唯一） |
| `type` | `tcp` / `udp` / `http` / `https` / `stcp` / `xtcp` |
| `localIP` / `localPort` | 本地转发目标 |
| `remotePort` | frps 暴露的端口（tcp/udp） |

> [!NOTE]
> 完整配置参考见 [frp 官方文档](https://github.com/fatedier/frp#configuration-files)。

## 构建方式

Release 模式 — 从 [GitHub Releases](https://github.com/fatedier/frp/releases) 下载预编译二进制，基于 `alpine:3` 打包。

## 构建触发

- 每日 UTC 08:00（北京时间 16:00）自动检查新版本
- 支持手动触发，可指定版本号
- 已存在的版本不会重复构建

