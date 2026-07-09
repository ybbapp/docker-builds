# unbound-python

多架构 Unbound server 镜像（`amd64` + `arm64`），参考 [NLnetLabs/pythonunbound](https://github.com/NLnetLabs/pythonunbound) 的方式从上游源码编译 Unbound，用于运行带 `cachedb`、`iterator`、`python` 模块支持的 DNS 服务端。

默认配置包含：

```yaml
server:
  module-config: "cachedb iterator python"
python:
  python-script: "/etc/unbound/python/noop.py"
```

> 说明：`cachedb iterator python` 不是 `unbound-checkconf` 白名单里的组合，但 Debian trixie 的 Unbound daemon 已编译 `cachedb`、`iterator`、`python`，并可以在安装 `python3-unbound` 后启动该模块栈。本镜像在构建和运行 smoke test 中验证 daemon 路径，而不是只依赖 `unbound-checkconf`。

## 镜像

| 镜像 | 说明 |
|:-----|:-----|
| `ghcr.io/ybbapp/unbound-python:latest` | 默认 Debian trixie + 自动解析的最新 Unbound upstream release tag |
| `ghcr.io/ybbapp/unbound-python:trixie` | Debian trixie |
| `ghcr.io/ybbapp/unbound-python:<debian_version>` | 通过 workflow 手动指定的 Debian 版本 |
| `ghcr.io/ybbapp/unbound-python:<unbound_version>` | 通过 workflow 自动解析或手动指定的 Unbound 版本 |

## 使用

启动 DNS server：

```bash
docker run --rm -p 5353:53/udp -p 5353:53/tcp ghcr.io/ybbapp/unbound-python:latest
```

查询测试：

```bash
dig @127.0.0.1 -p 5353 example.com A
```

挂载自定义 Python module：

```bash
docker run --rm \
  -p 5353:53/udp -p 5353:53/tcp \
  -v "$PWD/my-module.py:/etc/unbound/python/module.py:ro" \
  -v "$PWD/python.conf:/etc/unbound/unbound.conf.d/python.conf:ro" \
  ghcr.io/ybbapp/unbound-python:latest
```

`python.conf` 示例：

```yaml
python:
  python-script: "/etc/unbound/python/module.py"
```

也可以直接挂载完整配置覆盖 `/etc/unbound/unbound.conf`。

## 默认配置

默认 `/etc/unbound/unbound.conf`：

- 监听 `0.0.0.0:53` 和 `[::]:53`
- 允许容器网络访问（`access-control: 0.0.0.0/0 allow`、`::0/0 allow`）
- 禁用 chroot（`chroot: ""`），便于读取容器内挂载的配置、root hints 和 Python 脚本
- 使用 `/usr/share/dns/root.hints` 和 `/var/lib/unbound/root.key`
- `module-config: "cachedb iterator python"`
- `python-script: "/etc/unbound/python/noop.py"`
- `include-toplevel: "/etc/unbound/unbound.conf.d/*.conf"`

如需发布到公网，请自行收紧 `access-control`，避免变成开放递归解析器。

## 自定义版本

通过 `DEBIAN_VERSION` build arg 指定 Debian slim 镜像版本，通过 `UNBOUND_VERSION` 指定上游 Unbound 源码版本：

```bash
docker build \
  --build-arg DEBIAN_VERSION=trixie \
  --build-arg UNBOUND_VERSION=1.25.1 \
  -t unbound-python:1.25.1 \
  unbound-python/
```

GitHub Actions 中如果没有手动填写 `unbound_version`，会读取 `https://github.com/NLnetLabs/unbound.git` 的 `release-*` tags，过滤掉 RC tag，用最大稳定版本作为 `UNBOUND_VERSION` 传给 Docker build。手动填写时既可以填 `1.25.1`，也可以填 `release-1.25.1`。

## 构建方式

与 NLnetLabs 的参考 Dockerfile 一样，本镜像不依赖发行版预编译的 `unbound` 二进制，而是下载 `https://www.nlnetlabs.nl/downloads/unbound/unbound-${UNBOUND_VERSION}.tar.gz` 并源码编译：

```text
PYTHON_VERSION=3 ./configure \
  --with-pyunbound \
  --with-pythonmodule \
  --with-libevent \
  --with-libhiredis \
  --enable-cachedb
```

构建阶段会检查 `unbound -V`，确保包含 `--with-pythonmodule`、`--enable-cachedb`，并且 linked modules 包含 `python`、`cachedb`、`iterator`。
