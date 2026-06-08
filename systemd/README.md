# systemd

容器化的 init 系统镜像，用于需要完整 init 进程的场景（如 CI 测试、systemd 服务开发等）。

## 镜像

| 变体 | 基础镜像 | Init 系统 | 镜像 |
|:-----|:---------|:----------|:-----|
| debian | `debian` | systemd | `ghcr.io/ybbapp/systemd:debian` |
| alpine | `alpine` | OpenRC | `ghcr.io/ybbapp/systemd:alpine` |

> **注意**: Alpine Linux 原生不支持 systemd，使用 OpenRC 作为 init 系统。两者均提供完整的服务管理能力。

## 使用

```bash
# Debian (systemd)
docker run -d --privileged -v /sys/fs/cgroup:/sys/fs/cgroup:rw ghcr.io/ybbapp/systemd:debian

# Alpine (OpenRC)
docker run -d --privileged ghcr.io/ybbapp/systemd:alpine
```

### 自定义版本

通过 `VERSION` build arg 指定基础镜像版本：

```bash
# Debian bookworm
docker build --build-arg VERSION=bookworm -t systemd:bookworm systemd/debian/

# Alpine 3.20
docker build --build-arg VERSION=3.20 -t systemd:alpine3.20 systemd/alpine/
```

## 构建方式

基于上游官方基础镜像，安装对应 init 系统并清理不必要的服务单元。

参考: [j8r/dockerfiles](https://github.com/j8r/dockerfiles)
