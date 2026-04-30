# rembg

多架构 rembg 镜像（`amd64` + `arm64`），用于 AI 背景移除。

## 镜像

| 镜像 | 说明 |
|:-----|:-----|
| `ghcr.io/ybbapp/rembg:latest` | 默认 u2net 模型 |
| `ghcr.io/ybbapp/rembg:birefnet-general` | BiRefNet 高质量模型 |

## 使用

```bash
docker run -p 5000:7000 ghcr.io/ybbapp/rembg:latest s
```

指定模型启动：

```bash
docker run -p 5000:7000 ghcr.io/ybbapp/rembg:latest s --model birefnet-general
```

API 调用：

```bash
curl -F "file=@input.png" http://localhost:5000/api/remove -o output.png
```

## 构建方式

从 PyPI 安装 `rembg[cpu,cli]`，基于 `python:3.11-slim`（原生支持 amd64/arm64）。

构建时通过 `MODEL` 参数预下载模型，避免冷启动下载。

## 可用模型

| 模型 | 用途 |
|:-----|:-----|
| `u2net` | 通用（默认） |
| `u2netp` | 轻量通用 |
| `u2net_human_seg` | 人像分割 |
| `isnet-general-use` | DIS 通用 |
| `isnet-anime` | 动漫/插画 |
| `birefnet-general` | 高质量通用 |
| `birefnet-general-lite` | 轻量 BiRefNet |
| `birefnet-portrait` | 人像 |
| `silueta` | 快速通用 |
