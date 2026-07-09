# unbound-python

多架构 Python + Unbound 镜像（`amd64` + `arm64`），内置 `libunbound` 与 Debian 官方 `python3-unbound` 绑定，用于在 Python 程序中直接进行递归 DNS 解析、DNSSEC 校验等能力验证。

## 镜像

| 镜像 | 说明 |
|:-----|:-----|
| `ghcr.io/ybbapp/unbound-python:latest` | 默认 Debian bookworm |
| `ghcr.io/ybbapp/unbound-python:bookworm` | Debian bookworm |
| `ghcr.io/ybbapp/unbound-python:<debian_version>` | 通过 workflow 手动指定的 Debian 版本 |

## 使用

进入 Python REPL：

```bash
docker run --rm -it ghcr.io/ybbapp/unbound-python:latest
```

执行解析脚本：

```bash
docker run --rm ghcr.io/ybbapp/unbound-python:latest python - <<'PY'
import unbound

ctx = unbound.ub_ctx()
status, result = ctx.resolve('example.com', unbound.RR_TYPE_A, unbound.RR_CLASS_IN)

if status != 0:
    raise SystemExit(f'resolve failed: {status}')

print([addr for addr in result.data.address_list])
PY
```

作为基础镜像：

```dockerfile
FROM ghcr.io/ybbapp/unbound-python:latest
WORKDIR /app
COPY . .
CMD ["python", "main.py"]
```

## 自定义 Debian 版本

通过 `DEBIAN_VERSION` build arg 指定 Debian slim 镜像版本：

```bash
docker build --build-arg DEBIAN_VERSION=bookworm -t unbound-python:bookworm unbound-python/
```

## 构建方式

基于 `debian:<DEBIAN_VERSION>-slim`，通过 Debian apt 安装 `python3`、`libunbound` 与官方 `python3-unbound` 绑定。

构建阶段会运行一次 `example.com` A 记录解析作为 smoke test，确保 `libunbound` 与 Python 绑定可用。
