# singbox-build

自动编译 [sing-box](https://github.com/SagerNet/sing-box) 静态二进制，启用 `with_v2ray_api` 构建标签。

## 下载

从 [Releases](https://github.com/ybbapp/singbox-build/releases) 下载对应架构的二进制文件。

## 产物

| 文件 | 架构 | 说明 |
|:-----|:-----|:-----|
| `sing-box-linux-amd64` | x86_64 | Linux AMD64 静态二进制 |
| `sing-box-linux-arm64` | aarch64 | Linux ARM64 静态二进制 |
| `checksums.txt` | — | SHA256 校验 |

## 构建标签

```
with_gvisor,with_quic,with_dhcp,with_wireguard,with_utls,with_acme,
with_clash_api,with_v2ray_api,with_tailscale,with_ccm,with_ocm,
with_cloudflared,badlinkname,tfogo_checklinkname0
```

## 构建方式

- `CGO_ENABLED=0` 静态编译，无外部依赖
- 每日 UTC 08:00 自动检查新版本
- 支持手动触发指定版本
- 已存在的 Release 不会重复构建
