# sing-box

[sing-box](https://github.com/SagerNet/sing-box) 是一个通用代理平台，支持多种协议。

本镜像在官方默认构建标签基础上额外启用了 `with_v2ray_api`，提供 V2Ray API 统计功能支持。

## 镜像

| 镜像 | 说明 |
|:-----|:-----|
| `ghcr.io/ybbapp/sing-box` | sing-box（含 V2Ray API） |

## 标签

- `latest` — 跟踪上游最新 Release
- `v<version>` — 对应上游版本号，如 `v1.12.0`

## 构建标签

基于官方 `DEFAULT_BUILD_TAGS` + `with_v2ray_api`：

```
with_gvisor,with_quic,with_dhcp,with_wireguard,with_utls,with_acme,
with_clash_api,with_v2ray_api,with_tailscale,with_ccm,with_ocm,
with_cloudflared,badlinkname,tfogo_checklinkname0
```

与官方的区别：
- **新增** `with_v2ray_api` — 启用 V2Ray API 流量统计
- **未包含** `with_naive_outbound` — 该功能需要外部 `libcronet.so` 运行时依赖，与独立二进制目标冲突

## Docker Compose

```yaml
services:
  sing-box:
    image: ghcr.io/ybbapp/sing-box:latest
    restart: always
    volumes:
      - ./config.json:/etc/sing-box/config.json
    ports:
      - "1080:1080"
    cap_add:
      - NET_ADMIN
```

## 构建方式

Source 模式 — 从 [GitHub](https://github.com/SagerNet/sing-box) 拉取源码，使用 `CGO_ENABLED=0` 静态编译，产出不依赖系统共享库的独立二进制。

## 构建触发

- 每日 UTC 08:00（北京时间 16:00）自动检查新版本
- 支持手动触发，可指定版本号
- 已存在的版本不会重复构建
