# docker-builds

通过 GitHub Actions 自动构建开源项目的多架构 Docker 镜像，推送至 GHCR。

## 镜像列表

| 项目 | 镜像 | 说明 | 架构 |
|:-----|:-----|:-----|:-----|
| [frp](https://github.com/fatedier/frp) | `ghcr.io/ybbapp/frpc`<br>`ghcr.io/ybbapp/frps` | 内网穿透客户端 / 服务端 | `amd64`, `arm64` |

## 使用方式

### frpc (客户端)

```bash
docker pull ghcr.io/ybbapp/frpc:latest

# 指定版本
docker pull ghcr.io/ybbapp/frpc:v0.68.1

# 运行示例 (挂载配置文件)
docker run -d --restart=always --name frpc \
  -v /path/to/frpc.toml:/etc/frp/frpc.toml \
  ghcr.io/ybbapp/frpc:latest -c /etc/frp/frpc.toml
```

### frps (服务端)

```bash
docker pull ghcr.io/ybbapp/frps:latest

# 运行示例
docker run -d --restart=always --name frps \
  -v /path/to/frps.toml:/etc/frp/frps.toml \
  -p 7000:7000 -p 7500:7500 \
  ghcr.io/ybbapp/frps:latest -c /etc/frp/frps.toml
```

## 构建机制

- 每日 UTC 08:00 (北京时间 16:00) 自动检查 frp 最新 release
- 若检测到新版本，自动构建并推送多架构镜像
- 支持手动触发 (`workflow_dispatch`)，可指定版本号
- 镜像标签：`latest` + 版本号 (如 `v0.68.1`)

### 手动触发构建

在 GitHub Actions 页面选择 "Build frp images" workflow，点击 "Run workflow"，可选填版本号。

## 项目结构

```text
docker-builds/
├── .github/workflows/
│   └── frp.yml          # frp 构建工作流
├── frp/
│   ├── Dockerfile.frpc  # frpc 镜像定义
│   └── Dockerfile.frps  # frps 镜像定义
├── .gitignore
└── README.md
```

## 添加新项目

1. 在根目录创建项目文件夹 (如 `myproject/`)
2. 添加 Dockerfile
3. 在 `.github/workflows/` 下创建对应的工作流文件
4. 更新本 README 的镜像列表

