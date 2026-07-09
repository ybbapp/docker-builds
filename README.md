# docker-builds

通过 GitHub Actions 自动构建开源项目的多架构 Docker 镜像，推送至 GHCR。

## 镜像列表

| 项目 | 镜像 | 说明 | 构建方式 | 架构 |
|:-----|:-----|:-----|:---------|:-----|
| [frp](https://github.com/fatedier/frp) | `ghcr.io/ybbapp/frpc`<br>`ghcr.io/ybbapp/frps` | 内网穿透客户端 / 服务端 | Release 二进制 | `amd64`, `arm64` |
| [rembg](https://github.com/danielgatis/rembg) | `ghcr.io/ybbapp/rembg` | AI 背景移除 | PyPI 安装 | `amd64`, `arm64` |
| [sing-box](https://github.com/SagerNet/sing-box) | `ghcr.io/ybbapp/sing-box` | 通用代理平台（含 V2Ray API） | Source 编译 | `amd64`, `arm64` |
| [systemd](./systemd) | `ghcr.io/ybbapp/systemd:debian`<br>`ghcr.io/ybbapp/systemd:alpine` | 容器化 init 系统 (systemd / OpenRC) | 官方镜像组合 | `amd64`, `arm64` |
| [tailscale-exitnode](./tailscale-exitnode) | `ghcr.io/ybbapp/tailscale-exitnode` | sing-box + Tailscale exit node | 官方镜像组合 | `amd64`, `arm64` |
| [unbound-python](./unbound-python) | `ghcr.io/ybbapp/unbound-python` | Unbound server（cachedb + iterator + python） | Source 编译 | `amd64`, `arm64` |
| [v2ray-agent](https://github.com/mack-a/v2ray-agent) | `ghcr.io/ybbapp/v2ray-agent` | Xray/sing-box 一键脚本 | Source 编译 | `amd64`, `arm64` |

## 构建方式

本仓库支持两种构建模式：

- **Release 模式** — 从上游项目的 GitHub Release 下载预编译二进制打包为镜像。适用于未提供官方 Docker 镜像但有 Release 产物的项目（如 frp）。
- **Source 模式** — 从源码编译构建。适用于本组织 fork 并修改过的项目，需要自行编译。

## 项目结构

```text
docker-builds/
├── .github/workflows/
│   └── <project>.yml     # 每个项目对应一个工作流
├── <project>/
│   ├── Dockerfile.*      # 镜像定义
│   └── README.md         # 项目说明
├── .gitignore
└── README.md
```

## 添加新项目

1. 在根目录创建项目文件夹（如 `myproject/`）
2. 添加 Dockerfile 和 `README.md`
3. 在 `.github/workflows/` 下创建对应的工作流文件
4. 更新本 README 的镜像列表
